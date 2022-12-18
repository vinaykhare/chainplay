import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/play_activity_screen.dart';
import 'package:schedule_it/screens/schedule_list_screen.dart';
import 'package:schedule_it/widgets/schedule_activities.dart';

class PlaySchedule extends StatefulWidget {
  static String routename = "play_schedule";
  const PlaySchedule({super.key});
  @override
  State<PlaySchedule> createState() => _PlayScheduleState();
}

class _PlayScheduleState extends State<PlaySchedule> {
  late DateTime scheduleStartedAt;
  late Schedule schedule;
  late ScheduleList scheduleList;
  List<ScheduleActivity> activities = [];
  int invokeCounter = 0;
  bool initializing = true, scheduleExecuted = false;

  void updateWaitDuration() async {
    dynamic popResponse;
    NavigatorState nav = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 1));

    for (DateTime actStartDate = scheduleStartedAt;
        invokeCounter < schedule.activities.length;
        invokeCounter++) {
      Duration activityExecutedFor = const Duration(seconds: 0);
      Duration calculatedWaitDuration = const Duration(seconds: 0);
      Duration waitDurationDifferenceForRestScreen = const Duration(seconds: 0);
      activities[invokeCounter].at =
          activities[invokeCounter].at ?? actStartDate;

      Duration timeSpentSinceStartOfActivity =
          DateTime.now().difference(actStartDate);

      if (activities[invokeCounter].activityDuration.inSeconds > 0) {
        activityExecutedFor += activities[invokeCounter].activityDuration;
      } else {
        activityExecutedFor = calculatedWaitDuration;
      }

      if (!activities[invokeCounter].activityDone &&
          (timeSpentSinceStartOfActivity < activityExecutedFor ||
              (activities[invokeCounter].activityDuration.inSeconds <= 0 &&
                  activities[invokeCounter].activity.type !=
                      systemWaitActivityInDB) ||
              activities[invokeCounter].pausedAt != null)) {
        if (activities[invokeCounter].activityDuration.inSeconds > 0) {
          calculatedWaitDuration =
              activityExecutedFor - timeSpentSinceStartOfActivity;
        }
        popResponse = await nav.pushNamed(
          PlayActivity.routename,
          arguments: {
            "waitDuration": activities[invokeCounter].pausedAt ??
                (calculatedWaitDuration.inSeconds > 0
                    ? calculatedWaitDuration
                    : activities[invokeCounter].activityDuration),
            "scheduleActivity": activities[invokeCounter],
            "playRest": activities[invokeCounter].activity.type ==
                systemWaitActivityInDB,
            "running": activities[invokeCounter].pausedAt == null,
          },
        );

        if (popResponse != null) {
          if (popResponse["interruptAndCompleted"] == false) {
            activities[invokeCounter].pausedAt = popResponse["running"] == false
                ? popResponse["waitDuration"]
                : null;
            break;
          } else {
            activities[invokeCounter].restDone = true;
          }
        }

        activities[invokeCounter].activityDone = true;

        if (activities[invokeCounter].nextActivityAfter.inSeconds > 0) {
          popResponse = await nav.pushNamed(
            PlayActivity.routename,
            arguments: {
              "waitDuration": activities[invokeCounter].nextActivityAfter,
              "scheduleActivity": activities[invokeCounter],
              "playRest": true,
              "running": true,
            },
          );

          if (popResponse != null) {
            if (popResponse["interruptAndCompleted"] == false) {
              activities[invokeCounter].pausedAt =
                  popResponse["running"] == false
                      ? popResponse["waitDuration"]
                      : null;
              break;
            } else {
              activities[invokeCounter].restDone = true;
            }
          }
        }
      } else {
        activities[invokeCounter].activityDone = true;

        activityExecutedFor += activities[invokeCounter].nextActivityAfter;

        if (activities[invokeCounter].endedAt == null &&
            activities[invokeCounter].nextActivityAfter.inSeconds > 0 &&
            timeSpentSinceStartOfActivity < activityExecutedFor) {
          waitDurationDifferenceForRestScreen =
              activityExecutedFor - timeSpentSinceStartOfActivity;

          popResponse = await nav.pushNamed(
            PlayActivity.routename,
            arguments: {
              "waitDuration": waitDurationDifferenceForRestScreen.inSeconds > 0
                  ? waitDurationDifferenceForRestScreen
                  : activities[invokeCounter].nextActivityAfter,
              "scheduleActivity": activities[invokeCounter],
              "playRest": true,
              "running": true,
            },
          );

          if (popResponse != null) {
            if (popResponse["interruptAndCompleted"] == false) {
              activities[invokeCounter].pausedAt =
                  popResponse["running"] == false
                      ? popResponse["waitDuration"]
                      : null;
              break;
            }
          } else {
            activities[invokeCounter].restDone = true;
          }
        }
      }
      //activities[invokeCounter].restDone = true;

      actStartDate = activities[invokeCounter].endedAt =
          activities[invokeCounter].endedAt ?? DateTime.now();
      //actStartDate.add(activityExecutedFor);

      await scheduleList.updateScheduleActivityByActivityId(
        schedule,
        activities[invokeCounter],
      );
    }

    if (popResponse != null && popResponse["interruptAndCompleted"] == false) {
      await scheduleList.scheduleNotification(
          schedule, DateTime.now(), invokeCounter);
    } else {
      setState(() {
        scheduleExecuted = true;
      });

      await scheduleList.moveScheduleToHistory(schedule);
    }
    //nav.pop();
  }

  Future<bool> onPopOut() async {
    // await scheduleList.scheduleNotification(
    //     schedule, DateTime.now(), invokeCounter);
    if (scheduleExecuted) {
      await scheduleList.resetActivities(schedule);
    }
    return true;
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      scheduleList = Provider.of<ScheduleList>(context, listen: false);
      if (scheduleList.notificationCameForSchedule != null) {
        schedule = scheduleList.notificationCameForSchedule!;
        scheduleList.notificationCameForSchedule = null;
      } else {
        schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
      }
      activities = schedule.activities;
      if (schedule.at != null) {
        scheduleStartedAt = schedule.at!;
        updateWaitDuration();
      }
      initializing = false;
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
                    child: ScheduleActivities(
                      tempSchedule: schedule,
                      editActivity: null,
                      undoEdit: null,
                      showCheckBoxes: true,
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
                            : nav.pushReplacementNamed(
                                ScheduleListScreen.routename);
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
                        initialValue: schedule.name,
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
