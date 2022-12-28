import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/chain_event.dart';
import 'package:chain_events/models/chain_list.dart';
import 'package:chain_events/screens/play_wait_event_screen.dart';
import 'package:chain_events/screens/chain_list_screen.dart';
import 'package:chain_events/widgets/chain_events_widget.dart';

class PlayChain extends StatefulWidget {
  static String routename = "play_chain";
  const PlayChain({super.key});
  @override
  State<PlayChain> createState() => _PlayChainState();
}

class _PlayChainState extends State<PlayChain> {
  late Chain chain;
  late ChainList chainList;
  List<ChainEvent> activities = [];
  int invokeCounter = 0;
  bool initializing = true;

  void updateWaitDuration() async {
    dynamic popResponse;
    NavigatorState nav = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 1));
    await chainList.cancelScheduleNotificationExecution(
      chain,
    );
    DateTime chainExecutedTill = chain.at!;
    for (DateTime actStartDate = chain.at!;
        invokeCounter < chain.activities.length;
        invokeCounter++) {
      Duration eventExecutedFor = const Duration(seconds: 0);
      Duration calculatedWaitDuration = const Duration(seconds: 0);
      activities[invokeCounter].at =
          activities[invokeCounter].at ?? actStartDate;

      Duration timeSpentSinceStartOfEvent =
          DateTime.now().difference(actStartDate);

      if (activities[invokeCounter].eventDuration.inSeconds > 0) {
        eventExecutedFor += activities[invokeCounter].eventDuration;
        chainExecutedTill =
            chainExecutedTill.add(activities[invokeCounter].eventDuration);
      }

      if (activities[invokeCounter].endedAt == null &&
          activities[invokeCounter].event.type != systemStartEventInDB &&
          (chainExecutedTill.isAfter(DateTime.now()) ||
              (activities[invokeCounter].eventDuration.inSeconds <= 0 &&
                  activities[invokeCounter].event.type !=
                      systemWaitEventInDB))) {
        if (activities[invokeCounter].eventDuration.inSeconds > 0) {
          calculatedWaitDuration =
              eventExecutedFor - timeSpentSinceStartOfEvent;
        }
        popResponse = await nav.pushNamed(
          PlayWaitEvent.routename,
          arguments: {
            "waitDuration": activities[invokeCounter].eventDurationLeft ??
                (calculatedWaitDuration.inSeconds > 0
                    ? calculatedWaitDuration
                    : activities[invokeCounter].eventDuration),
            "chainEvent": activities[invokeCounter],
            "playRest":
                activities[invokeCounter].event.type == systemWaitEventInDB,
            "running": activities[invokeCounter].eventDurationLeft == null,
          },
        );

        if (popResponse != null) {
          if (popResponse["interruptAndCompleted"] == false) {
            activities[invokeCounter].eventDurationLeft =
                popResponse["running"] == false
                    ? popResponse["waitDuration"]
                    : null;
            break;
          } else {
            activities[invokeCounter].eventDurationLeft = null;
            activities[invokeCounter].isInterrupted = true;
          }
        }
      }

      activities[invokeCounter].eventDone = true;
      actStartDate = activities[invokeCounter].endedAt =
          activities[invokeCounter].endedAt ?? DateTime.now();
      //actStartDate.add(eventExecutedFor);

      await chainList.updateChainEventExecutionByEventId(
        chain,
        activities[invokeCounter],
      );
    }

    if (popResponse != null && popResponse["interruptAndCompleted"] == false) {
      // await chainList.scheduleNotification(
      //     chain, DateTime.now(), invokeCounter);
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
            await chainList.moveChainToHistory(parentChain);
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
                    child: ChainEventsWidget(
                      tempChain: chain,
                      editEvent: null,
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
