import 'dart:async';

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
  late ChainList chainList;
  List<ChainActivity> activities = [];
  int invokeCounter = 0;
  bool initializing = true;

  void updateWaitDuration() async {
    dynamic popResponse;
    NavigatorState nav = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 1));
    await chainList.cancelScheduleNotificationExecution(
      chain,
    );
    //DateTime pivotStartDateTime = chain.pivotDate!;
    for (DateTime actStartDate = chain.at!;
        invokeCounter < chain.activities.length;
        invokeCounter++) {
      Duration activityExecutedFor = const Duration(seconds: 0);
      Duration calculatedWaitDuration = const Duration(seconds: 0);
      Duration timeSpentSinceStartOfActivity = const Duration(seconds: 0);
      activities[invokeCounter].at =
          activities[invokeCounter].at ?? actStartDate;

      activityExecutedFor = activities[invokeCounter].activityDurationLeft ??
          activities[invokeCounter].activityDuration;
      chain.pivotDate = activities[invokeCounter].endedAt ??
          activities[invokeCounter].at!.add(activityExecutedFor);

      timeSpentSinceStartOfActivity = DateTime.now().difference(actStartDate);

      bool validSystemWaitActivity =
          activities[invokeCounter].activity.type == systemWaitActivityInDB &&
              activities[invokeCounter].activityDuration.inSeconds > 0 &&
              !chain.pivotDate!.isBefore(DateTime.now());
      bool validUserWaitActivity =
          activities[invokeCounter].activity.type == waitActivityInDB &&
              (!chain.pivotDate!.isBefore(DateTime.now()) ||
                  activities[invokeCounter].activityDuration.inSeconds <= 0);
      bool conditionToRunActivity = activities[invokeCounter].endedAt == null &&
          activities[invokeCounter].activity.type != systemStartActivityInDB &&
          (validSystemWaitActivity ||
              validUserWaitActivity ||
              activities[invokeCounter].activityDurationLeft != null);

      if (conditionToRunActivity) {
        //Don't run system wait activity when its duration is 0 seconds.

        if (activities[invokeCounter].activityDuration.inSeconds > 0) {
          calculatedWaitDuration =
              activityExecutedFor - timeSpentSinceStartOfActivity;
        }
        popResponse = await nav.pushNamed(
          PlayWaitActivity.routename,
          arguments: {
            "waitDuration": activities[invokeCounter].activityDurationLeft ??
                (calculatedWaitDuration.inSeconds > 0
                    ? calculatedWaitDuration
                    : activities[invokeCounter].activityDuration),
            "chainActivity": activities[invokeCounter],
            "playRest": activities[invokeCounter].activity.type ==
                systemWaitActivityInDB,
            "running": activities[invokeCounter].activityDurationLeft == null,
            "screenImage": activities[invokeCounter]
                .activity
                .specification?[activitySpecImagePath]
          },
        );

        if (popResponse != null) {
          if (popResponse["interruptAndCompleted"] == false) {
            activities[invokeCounter].activityDurationLeft =
                popResponse["running"] == false
                    ? popResponse["waitDuration"]
                    : null;
            if (popResponse["resumedAt"] != null) {
              chain.pivotDate = popResponse["resumedAt"];
            }
            break;
          } else {
            activities[invokeCounter].activityDurationLeft = null;
            activities[invokeCounter].isInterrupted = true;
          }
        }
      }

      activities[invokeCounter].activityDone = true;
      actStartDate = activities[invokeCounter].endedAt =
          activities[invokeCounter].at!.add(Duration(
              seconds: activities[invokeCounter].activityDuration.inSeconds));
      if (activities[invokeCounter].activityDuration.inSeconds <= 0 &&
          activities[invokeCounter].activity.type != systemStartActivityInDB &&
          activities[invokeCounter].activity.type != systemWaitActivityInDB) {
        actStartDate = activities[invokeCounter].endedAt = DateTime.now();
        chain.pivotDate = activities[invokeCounter].endedAt!;
      }
      await chainList.updateChainExecution(chain);
      await chainList.updateChainActivityExecutionByActivityId(
        chain,
        activities[invokeCounter],
      );
    }

    if (popResponse != null && popResponse["interruptAndCompleted"] == false) {
      // await chainList.scheduleNotification(
      //     chain, DateTime.now(), invokeCounter);
      if (popResponse["running"] == false &&
          popResponse["waitDuration"] != null) {
        chain.pivotDate = chain.pivotDate!.add(popResponse["waitDuration"]);
      }
    } else {
      Chain parentChain =
          chainList.chains.firstWhere((sch) => sch.title == chain.title);
      setState(() {
        chain.chainStatus = statusDone;
        parentChain.chainStatus = statusNotStarted;
        chain.endedAt = DateTime.now();
        parentChain.endedAt = null;
      });

      await chainList.updateChain(parentChain);
      await chainList.updateChainExecution(chain);

      if (parentChain.repeatType != repeatTypeDoesNotRepeat) {
        Chain chainInExecution =
            await chainList.startChainExecution(parentChain);
        chainList.scheduleNotificationForExecution(
            chainInExecution, chainInExecution.at!);
      }
    }
    //nav.pop();
  }

  Future<bool> onPopOut() async {
    // await chainList.scheduleNotification(
    //     chain, DateTime.now(), invokeCounter);
    if (chain.chainStatus == statusDone) {
      //await chainList.resetActivities(chain);
    } else {
      await chainList.scheduleNotificationForExecution(
        chain,
        chain.at!,
      );
    }
    return true;
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
      Map<String, dynamic> schArg = chainList.notificationCameAs != null
          ? chainList.notificationCameAs!
          : ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      Chain parentChainItem = chainList.chains
          .firstWhere((sch) => sch.title == schArg[payLoadChainName]);
      chain = parentChainItem.chainHistory.firstWhere(
          (schEx) => schEx.chainExecutionId == schArg[payLoadChainExecId]);
      //}
      activities = chain.activities;
      if (chain.chainStatus == statusExecuting &&
          !chain.at!.isAfter(DateTime.now())) {
        updateWaitDuration();
      } else {
        invokeCounter = activities.length;
      }
      initializing = false;
      chainList.notificationCameAs = null;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
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
                        style: Theme.of(context).textTheme.headline6,
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
                      onPressed: invokeCounter >= activities.length
                          ? null
                          : () {
                              invokeCounter = 0;
                              updateWaitDuration();
                            },
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
