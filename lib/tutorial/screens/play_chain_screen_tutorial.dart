import 'dart:async';

import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/tutorial/screens/play_wait_activity_screen_tutorial.dart';
import 'package:chain_activities/widgets/cat_text_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_activities_widget.dart';

class PlayChainTutorial extends StatefulWidget {
  static String routename = "play_chain_tutorial";
  const PlayChainTutorial({super.key});
  @override
  State<PlayChainTutorial> createState() => _PlayChainTutorialState();
}

class _PlayChainTutorialState extends State<PlayChainTutorial> {
  late Chain chain;
  late Chain parentChain;
  late ChainList chainList;
  int invokeCounter = 0;
  ChainActivity? chainActivityPaused;
  bool initializing = true;
  String? playChainAction;

  Future<void> playTheChain() async {
    NavigatorState nav = Navigator.of(context);
    await chainList.loadInterstitialAd();
    for (invokeCounter = 0; invokeCounter < 2; invokeCounter++) {
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

      await nav.pushNamed(
        PlayWaitActivityTutorial.routename,
        arguments: {
          "waitDuration": waitDuration,
          "chainActivity": chainActivity,
          "playScreenType": playScreenType,
          "running": running,
          "screenImage": screenImage,
        },
      );

      chainActivity.activityDone = true;
      chainActivity.endedAt = DateTime.now();
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
    bool? permissionGranted = await chainList.askForNotificationPermission();

    if (permissionGranted != null && permissionGranted == true) {
      // await chainList.showNotification();
      await chainList.scheduleNotificationForActivityCompletion(
        chain,
        chainActivityPaused!,
        DateTime.now().add(chainActivityPaused!.activityDurationLeft!),
      );
    } else {
      scms.showSnackBar(
        SnackBar(
          content: const Text(
            "CAT do not have permission to send Notification.",
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
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
      Map<String, dynamic> chArg =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

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
    double appWidth = MediaQuery.of(context).size.width - 16;
    return IgnorePointer(
      ignoring: true,
      child: Semantics(
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
                    key: KeyHelper.playChainKey,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CatTextButton(
                          key: KeyHelper.playChainStopChainKey,
                          buttonLabel: "Stop",
                          buttonAction: () {},
                          buttonIcon: Icons.stop_circle,
                        ),
                        Container(
                          key: KeyHelper.playChainRunInBackgroundKey,
                          width: appWidth * 0.75,
                          height: appHeight * 0.06,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(
                                30,
                              ),
                              bottomLeft: Radius.circular(
                                30,
                              ),
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (chainActivityPaused != null &&
                                    chainActivityPaused!.endedAt == null &&
                                    chain.notificationId == noValueInDB)
                                  CatTextButton(
                                    buttonLabel:
                                        "Play the Chain, in Background",
                                    buttonAction: () {},
                                    buttonIcon: Icons.play_circle,
                                  )
                                else if (chain.notificationId != noValueInDB)
                                  CatTextButton(
                                    buttonLabel:
                                        "Refresh, for the latest status",
                                    buttonAction: () {},
                                    buttonIcon: Icons.refresh_outlined,
                                  )
                                else
                                  CatTextButton(
                                    buttonLabel:
                                        "Play the Chain, Interactively",
                                    buttonAction: () {},
                                    buttonIcon: Icons.arrow_forward_outlined,
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Row(
            children: [
              IconButton(
                key: KeyHelper.playChainBackwardButtonKey,
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_back,
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
                key: KeyHelper.playChainForwardButtonKey,
                onPressed: () {},
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
