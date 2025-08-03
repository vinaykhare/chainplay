import 'dart:async';

import 'package:chain_activities/helpers/common_logic.dart';
import 'package:chain_activities/helpers/common_ui.dart';
import 'package:chain_activities/helpers/content_transformer.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/widgets/cat_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/play_wait_activity_screen.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/widgets/chain_activities_widget.dart';

class PlayChain extends StatefulWidget {
  static String routename = "play_chain";
  const PlayChain({super.key});
  @override
  State<PlayChain> createState() => _PlayChainState();
}

class _PlayChainState extends State<PlayChain> {
  late Chain chain;
  late Chain parentChain;
  late ChainList chainList;
  int invokeCounter = 0;
  ChainActivity? chainActivityPaused;
  bool initializing = true, isLandScape = false;
  String? playChainAction;

  Future<void> setOrietation(bool orientationLandScape) async {
    await CommonLogic().setOrietation(orientationLandScape);
    isLandScape = orientationLandScape;
  }

  Future<void> playTheChain() async {
    dynamic popResponse;
    bool orientationLandScape = isLandScape;
    NavigatorState nav = Navigator.of(context);
    await chainList.loadInterstitialAd();
    for (invokeCounter = 0;
        invokeCounter < chain.activities.length;
        invokeCounter++) {
      ChainActivity chainActivity = chain.activities[invokeCounter];
      if ((chainActivity.endedAt != null &&
              chainActivity.activityDone == true) ||
          chainActivity.activity.type == systemStartActivityInDB ||
          (chainActivity.activity.type == systemWaitActivityInDB &&
              chainActivity.activityDuration.inSeconds <= 0 &&
              invokeCounter < chain.activities.length - 1)) {
        chainActivity.endedAt = chainActivity.endedAt ?? DateTime.now();
        continue;
      }

      if (chainActivity.endedAt != null &&
          chainActivity.activityDone == false &&
          chainActivity.endedAt!.isBefore(DateTime.now())) {
        await cancelNotificationAndCompleteActivity(chain, chainActivity);
        chainActivityPaused = null;
        continue;
      }

      chainActivity.at = chainActivity.at ?? DateTime.now();

      Duration waitDuration = chainActivity.activityDurationLeft != null
          ? chainActivity.activityDurationLeft!
          : chainActivity.activityDuration;
      int playScreenType = invokeCounter >= chain.activities.length - 1
          ? systemEndActivityInDB
          : chainActivity.activity.type;
      bool running = chainActivity.activityDurationLeft == null ||
          playChainAction == playChainActionPlay;
      String screenImage =
          chainActivity.activity.specification?[activitySpecImagePath] ?? "";

      // if (invokeCounter >= chain.activities.length) {
      //   break;
      // }

      // if (parentChain.notificationId == trueInDB &&
      //     waitDuration.inSeconds > 0) {
      //   break;
      // }
      String textToSpeak = chainActivity.activity.title;

      if (chainList.notificationHelper.isAppSoundEnabled()) {
        textToSpeak = chainActivity.activity.type == systemWaitActivityInDB
            ? invokeCounter < chain.activities.length - 1
                ? waitDuration.inSeconds > 0 && waitDuration.inSeconds <= 10
                    ? "Take Rest"
                    : "Take Rest. Next Activity will start ${ContentTransformer.durationToString(waitDuration)}."
                : "Congratulations, all the chain activities are executed. Please choose, if you want to restart this chain, or, just mark it complete."
            : waitDuration.inSeconds > 0 && waitDuration.inSeconds <= 10
                ? chainActivity.activity.title
                : "Activity ${chainActivity.activity.title} has started. It will complete ${ContentTransformer.durationToString(waitDuration)}.";

        if (chainActivity.activityDurationLeft != null &&
            waitDuration.inSeconds > 10 &&
            playChainAction == playChainActionPause) {
          textToSpeak += " after resuming.";
        }
      } else {
        textToSpeak = chainActivity.activity.type == systemWaitActivityInDB
            ? invokeCounter < chain.activities.length - 1
                ? "Take Rest"
                : "Done"
            : chainActivity.activity.title;
      }

      await chainList.speakTextWithoutWait(textToSpeak);
      popResponse = await nav.pushNamed(
        PlayWaitActivity.routename,
        arguments: {
          "waitDuration": waitDuration,
          "chainActivity": chainActivity,
          "playScreenType": playScreenType,
          "running": running,
          "screenImage": screenImage,
          "orientationLandScape": orientationLandScape,
          // "textToSpeak": textToSpeak,
        },
      );
      await chainList.stopSpeech();

      if (popResponse != null) {
        isLandScape =
            orientationLandScape = popResponse["orientationLandScape"];
        if (popResponse["interruptAndCompleted"] == false) {
          chainActivity.activityDurationLeft = popResponse["running"] == false
              ? popResponse["waitDuration"]
              : null;
          // if (popResponse["resumedAt"] != null) {
          //   chain.pivotDate = popResponse["resumedAt"];
          // }
          await chainList.updateChainActivityExecutionByActivityId(
            chain,
            chainActivity,
          );
          if (chainActivity.activityDurationLeft != null &&
              chainActivity.activityDurationLeft!.inMicroseconds != 0) {
            chainActivityPaused = chainActivity;
            playChainAction = playChainActionPause;
          }

          if (popResponse["notify"] == true) {
            await scheduleActivity();
          }

          break;
        } else {
          chainActivity.activityDurationLeft = null;
          chainActivity.isInterrupted = true;
        }
      }

      chainActivity.activityDone = true;
      chainActivity.endedAt = DateTime.now();
      await chainList.updateChainActivityExecutionByActivityId(
        chain,
        chainActivity,
      );
    }

    if (popResponse != null) {
      if (popResponse["interruptAndCompleted"] == false) {
        // await chainList.scheduleNotification(
        //     chain, DateTime.now(), invokeCounter);
        if (popResponse["running"] == false &&
            popResponse["waitDuration"] != null) {
          chain.pivotDate = chain.pivotDate!.add(popResponse["waitDuration"]);
          await chainList.updateChainExecution(chain);
        }
      } else {
        // Chain parentChain =
        //     chainList.chains.firstWhere((sch) => sch.title == chain.title);

        chain.chainStatus = statusDone;
        //parentChain.chainStatus = statusNotStarted;
        chain.endedAt = DateTime.now();
        //parentChain.endedAt = null;

        //await chainList.updateChain(parentChain);
        await chainList.updateChainExecution(chain);

        await chainList.completeTheChain(chain);

        if (popResponse["completionMessage"] ==
            chainActivityCompletionMessageRestart) {
          parentChain.at = popResponse["nextChainStartTime"];
          popResponse = null;
          chain = await chainList.startChainExecution(parentChain);
          invokeCounter = 0;
          playChainAction = playChainActionPlay;
          if (chain.notificationId != trueInDB) {
            playTheChain();
          }
        } else {
          if (chainList.interstitialAd != null) {
            await chainList.interstitialAd!.show();
          }
        }
      }
      //nav.pop();
    }
  }

  Future<void> cancelNotificationAndCompleteActivity(
      Chain chain, ChainActivity chainActivity) async {
    await chainList.cancelScheduledNotification(chain);
    await chainList.cancelScheduledNotificationExecution(chain);
    chainActivity.activityDurationLeft = null;
    chainActivity.activityDone = true;
    await chainList.updateChainActivityExecutionByActivityId(
      chain,
      chainActivity,
    );
  }

  Future<void> scheduleActivity() async {
    ScaffoldMessengerState scms = ScaffoldMessenger.of(context);
    String? scheduleNotificationResponse =
        await chainList.scheduleNotificationForActivityCompletion(
      chain,
      chainActivityPaused!,
      DateTime.now().add(chainActivityPaused!.activityDurationLeft!),
    );

    if (scheduleNotificationResponse != null) {
      scms.showSnackBar(
        SnackBar(
          content: Text(
            scheduleNotificationResponse,
          ),
          action: SnackBarAction(
            //textColor: Colors.white,
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> cancelSchedule() async {
    bool? dialogResponse = await CommonUI().confirmScheduleCancelation(context);

    if (dialogResponse == false) {
      // nav.pop();
      return;
    } else {
      chainActivityPaused!.isInterrupted = true;
      chainActivityPaused!.endedAt = DateTime.now();
      await cancelNotificationAndCompleteActivity(
        chain,
        chainActivityPaused!,
      );

      chain.at = DateTime.now();
      await chainList.updateChainExecution(chain);

      setState(() {
        chainActivityPaused = null;
        invokeCounter++;
      });
      playTheChain();
    }
  }

  Future<bool> onPopOut() async {
    await chainList.loadInterstitialAd();
    if (chainList.interstitialAd != null) {
      await chainList.interstitialAd!.show();
      await chainList.interstitialAd!.dispose();
    }
    chainList.interstitialAd = null;
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    chainList.disposeAds();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      chainList = Provider.of<ChainList>(context, listen: false);

      // if (chainList.notificationCameForChain != null) {
      //   chain = chainList.notificationCameForChain!;
      //   chainList.notificationCameForChain = null;
      // } else {
      Map<String, dynamic> chArg;
      if (chainList.notificationCameAs != null &&
          chainList.notificationCameAs!.isNotEmpty) {
        chArg = chainList.notificationCameAs!;
      } else {
        chArg =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      }

      playChainAction = chArg[payLoadChainAction];
      invokeCounter = chArg[payLoadChainActivityIndex];

      parentChain = chainList.chains
          .firstWhere((ch) => ch.title == chArg[payLoadChainName]);
      chain = parentChain.chainHistory.firstWhere(
        (schEx) => schEx.chainExecutionId == chArg[payLoadChainExecId],
      );

      if (chain.activities[invokeCounter].activityDurationLeft != null &&
          chain.activities[invokeCounter].activityDuration.inSeconds > 0) {
        chainActivityPaused = chain.activities[invokeCounter];
        if (chainActivityPaused!.endedAt != null &&
            chainActivityPaused!.endedAt!.isBefore(DateTime.now())) {
          cancelNotificationAndCompleteActivity(chain, chainActivityPaused!);
          chainActivityPaused = null;
        }
      }

      if (chain.chainStatus == statusExecuting &&
          playChainAction == playChainActionPlay) {
        playTheChain();
      } else if (chain.chainStatus != statusExecuting) {
        invokeCounter = chain.activities.length;
      } else {
        //
      }

      initializing = false;
      chainList.notificationCameAs = null;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    // double appWidth = MediaQuery.of(context).size.width - 16;
    return Semantics(
      label: "Play Chain Screen",
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            // margin: const EdgeInsets.only(top: 50),
            // padding: const EdgeInsets.all(10),
            height: appHeight,
            // width: appWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChainActivitiesWidget(
                      tempChain: chain,
                      editActivity: null,
                      undoEdit: null,
                    ),
                  ),
                ),
                if (invokeCounter < chain.activities.length)
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          // buttonLabel: "Stop",
                          style: ButtonStyle(
                            iconColor: WidgetStateProperty.resolveWith(
                              (states) => Theme.of(context).colorScheme.error,
                            ),
                          ),
                          // buttonAction :
                          onPressed: () async {
                            NavigatorState nav = Navigator.of(context);
                            bool? dialogResponse = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm to Stop"),
                                  content: const Text(
                                      "Are you sure about stopping this chain execution?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        "Yes, I am Sure!",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        "No, my bad!",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inverseSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (dialogResponse == true) {
                              chainList.stopChainExecution(parentChain);
                              nav.pushReplacementNamed(
                                ViewChain.routename,
                                arguments: {
                                  "chain": parentChain,
                                },
                              );
                            }
                          },
                          // buttonIcon: Icons.stop_circle,
                          icon: Icon(Icons.stop_circle),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (invokeCounter <= 0 &&
                                  chain.at != null &&
                                  chain.at!.isAfter(DateTime.now()))
                                CatTextButton(
                                  buttonLabel: "Cancel Schedule & Start Now",
                                  buttonAction: (chain.notificationId ==
                                              noValueInDB &&
                                          (chainActivityPaused == null ||
                                              chainActivityPaused!.endedAt ==
                                                  null))
                                      ? () {
                                          chainActivityPaused = null;
                                          playTheChain();
                                        }
                                      : () async {
                                          await cancelSchedule();
                                        },
                                  buttonIcon: Icons.free_cancellation_outlined,
                                )
                              else if (chainActivityPaused != null &&
                                  chainActivityPaused!.endedAt == null &&
                                  chain.notificationId == noValueInDB)
                                CatTextButton(
                                  buttonLabel: "Play the Chain, in Background",
                                  buttonAction: scheduleActivity,
                                  buttonIcon: Icons.play_circle,
                                )
                              else if (chain.notificationId != noValueInDB)
                                CatTextButton(
                                  buttonLabel: "Refresh, for the latest status",
                                  buttonAction: () async {
                                    if (chainActivityPaused!.endedAt!.isBefore(
                                      DateTime.now(),
                                    )) {
                                      await cancelNotificationAndCompleteActivity(
                                          chain, chainActivityPaused!);

                                      chainActivityPaused = null;
                                      invokeCounter++;
                                    } else {
                                      setState(() {});
                                    }
                                  },
                                  buttonIcon: Icons.refresh_outlined,
                                )
                              else
                                CatTextButton(
                                  buttonLabel: "Play the Chain, Interactively",
                                  buttonAction: () {
                                    chainActivityPaused = null;
                                    playTheChain();
                                  },
                                  buttonIcon: Icons.arrow_forward_outlined,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          style: ButtonStyle(
                            iconColor: WidgetStateProperty.resolveWith(
                              (states) => Theme.of(context).colorScheme.error,
                            ),
                          ),
                          icon: Icon(
                            Icons.screen_rotation_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              setOrietation(!isLandScape);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  NavigatorState nav = Navigator.of(context);
                  bool allWell = await onPopOut();
                  allWell && nav.canPop()
                      ? nav.pop()
                      : nav.pushNamed(ChainListScreen.routename);
                },
                icon: Semantics(
                  label: "Go back to previous screen",
                  child: const Icon(
                    Icons.arrow_back,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  initialValue: chain.title,
                  enabled: false,
                ),
              ),
              IconButton(
                onPressed: invokeCounter < chain.activities.length
                    ? (chain.notificationId == noValueInDB &&
                            (chainActivityPaused == null ||
                                chainActivityPaused!.endedAt == null))
                        ? () {
                            chainActivityPaused = null;
                            playTheChain();
                          }
                        : () async {
                            await cancelSchedule();
                          }
                    : null,
                icon: const Icon(
                  Icons.arrow_forward,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
