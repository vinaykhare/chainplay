import 'dart:async';

import 'package:chain_activities/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
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
  late Chain parentChainItem;
  late ChainList chainList;
  int invokeCounter = 0;
  bool initializing = true;
  //bool buildDone = false;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     buildDone = true;
  //   });
  // }

  Future<void> playTheChain() async {
    dynamic popResponse;
    NavigatorState nav = Navigator.of(context);
    await chainList.loadInterstitialAd();
    for (invokeCounter = 0;
        invokeCounter < chain.activities.length;
        invokeCounter++) {
      // Map<String, dynamic> dryRunResult =
      //     await chainList.executeChainFurtherPossible(chain, invokeCounter);
      ChainActivity chainActivity = chain.activities[invokeCounter];
      if (chainActivity.endedAt != null ||
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
      bool running = chainActivity.activityDurationLeft == null;
      String screenImage =
          chainActivity.activity.specification?[activitySpecImagePath] ?? "";

      // if (invokeCounter >= chain.activities.length) {
      //   break;
      // }

      // if (parentChainItem.notificationId == trueInDB &&
      //     waitDuration.inSeconds > 0) {
      //   break;
      // }

      String textToSpeak = chainActivity.activity.type == systemWaitActivityInDB
          ? invokeCounter < chain.activities.length - 1
              ? "Take Rest. Next Activity will start ${HelperFunctions.durationToString(waitDuration)}."
              : "Complete the chain by pressing done or go forward."
          : "Activity ${chainActivity.activity.title} has started. It will complete ${HelperFunctions.durationToString(waitDuration)}.";
      if (chainActivity.activityDurationLeft != null &&
          waitDuration.inSeconds > 0) {
        textToSpeak += " after resuming.";
      }
      await chainList.speakTextWithoutWait(textToSpeak);
      // while (!buildDone) {
      //   Future.delayed(
      //     const Duration(microseconds: 1),
      //   );
      // }
      popResponse = await nav.pushNamed(
        PlayWaitActivity.routename,
        arguments: {
          "waitDuration": waitDuration,
          "chainActivity": chainActivity,
          "playScreenType": playScreenType,
          "running": running,
          "screenImage": screenImage,
          // "textToSpeak": textToSpeak,
        },
      );
      await chainList.stopSpeech();

      if (popResponse != null) {
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
          break;
        } else {
          chainActivity.activityDurationLeft = null;
          chainActivity.isInterrupted = true;
        }
      }

      chainActivity.activityDone = true;
      // chainActivity.endedAt = chainActivity.at!
      //     .add(Duration(seconds: chainActivity.activityDuration.inSeconds));
      chainActivity.endedAt = DateTime.now();
      // if (chainActivity.activityDuration.inSeconds <= 0 &&
      //     chainActivity.activity.type != systemStartActivityInDB &&
      //     chainActivity.activity.type != systemWaitActivityInDB) {
      //   chainActivity.endedAt = DateTime.now();
      //   chain.pivotDate = chainActivity.endedAt!;
      // }
      // await chainList.updateChainExecution(chain);
      await chainList.updateChainActivityExecutionByActivityId(
        chain,
        chainActivity,
      );
    }

    if (popResponse != null && popResponse["interruptAndCompleted"] == false) {
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
      if (chainList.interstitialAd != null) {
        await chainList.interstitialAd!.show();
      }
      await chainList.completeTheChain(chain);
    }
    //nav.pop();
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
      parentChainItem = chainList.chains
          .firstWhere((ch) => ch.title == chArg[payLoadChainName]);
      chain = parentChainItem.chainHistory.firstWhere(
        (schEx) => schEx.chainExecutionId == chArg[payLoadChainExecId],
      );
      //}

      if (chain.chainStatus == statusExecuting) {
        playTheChain();
      } else {
        invokeCounter = chain.activities.length;
      }
      initializing = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return Semantics(
      label: "Play Chain Screen",
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
              // margin: const EdgeInsets.only(top: 50),
              // padding: const EdgeInsets.all(10),
              height: appHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          NavigatorState nav = Navigator.of(context);
                          bool allWell = await onPopOut();
                          allWell && nav.canPop()
                              ? nav.pop()
                              : nav.pushNamed(ChainListScreen.routename);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            floatingLabelAlignment:
                                FloatingLabelAlignment.center,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          initialValue: chain.title,
                          enabled: false,
                        ),
                      ),
                      IconButton(
                        onPressed: invokeCounter >= chain.activities.length
                            ? null
                            : () {
                                invokeCounter = 0;
                                playTheChain();
                              },
                        icon: chain.notificationId == trueInDB
                            ? const Icon(Icons.refresh)
                            : const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
