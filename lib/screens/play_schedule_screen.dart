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
  late Schedule schedule;
  late ScheduleList scheduleList;
  List<ScheduleActivity> activities = [];
  int invokeCounter = 0;
  bool initializing = true;

  void updateWaitDuration() async {
    dynamic popResponse;
    NavigatorState nav = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 1));

    for (DateTime? actStartDate = schedule.at;
        invokeCounter < schedule.activities.length;
        invokeCounter++) {
      Duration activityExecutedFor = const Duration(seconds: 0);
      Duration calculatedWaitDuration = const Duration(seconds: 0);
      activities[invokeCounter].at =
          activities[invokeCounter].at ?? actStartDate;

      Duration timeSpentSinceStartOfActivity =
          DateTime.now().difference(actStartDate!);

      if (activities[invokeCounter].activityDuration.inSeconds > 0) {
        activityExecutedFor += activities[invokeCounter].activityDuration;
      } else {
        activityExecutedFor = calculatedWaitDuration;
      }

      if (!activities[invokeCounter].activityDone &&
          activities[invokeCounter].activity.type != systemStartActivityInDB &&
          (timeSpentSinceStartOfActivity < activityExecutedFor ||
              (activities[invokeCounter].activityDuration.inSeconds <= 0 &&
                  activities[invokeCounter].activity.type !=
                      systemWaitActivityInDB) ||
              activities[invokeCounter].activityDurationLeft != null)) {
        if (activities[invokeCounter].activityDuration.inSeconds > 0) {
          calculatedWaitDuration =
              activityExecutedFor - timeSpentSinceStartOfActivity;
        }
        popResponse = await nav.pushNamed(
          PlayActivity.routename,
          arguments: {
            "waitDuration": activities[invokeCounter].activityDurationLeft ??
                (calculatedWaitDuration.inSeconds > 0
                    ? calculatedWaitDuration
                    : activities[invokeCounter].activityDuration),
            "scheduleActivity": activities[invokeCounter],
            "playRest": activities[invokeCounter].activity.type ==
                systemWaitActivityInDB,
            "running": activities[invokeCounter].activityDurationLeft == null,
          },
        );

        if (popResponse != null) {
          if (popResponse["interruptAndCompleted"] == false) {
            activities[invokeCounter].activityDurationLeft =
                popResponse["running"] == false
                    ? popResponse["waitDuration"]
                    : null;
            break;
          } else {
            activities[invokeCounter].isInterrupted = true;
          }
        }

        activities[invokeCounter].activityDone = true;
      } else {
        activities[invokeCounter].activityDone = true;
      }
      //activities[invokeCounter].isInterrupted = true;

      actStartDate = activities[invokeCounter].endedAt =
          activities[invokeCounter].endedAt ?? DateTime.now();
      //actStartDate.add(activityExecutedFor);

      await scheduleList.updateScheduleActivityExecutionByActivityId(
        schedule,
        activities[invokeCounter],
      );
    }

    if (popResponse != null && popResponse["interruptAndCompleted"] == false) {
      // await scheduleList.scheduleNotification(
      //     schedule, DateTime.now(), invokeCounter);
    } else {
      Schedule parentSchedule =
          scheduleList.schedules.firstWhere((sch) => sch.name == schedule.name);
      setState(() {
        schedule.scheduleStatus = statusDone;
        parentSchedule.scheduleStatus = statusNotStarted;
        schedule.endedAt = DateTime.now();
        parentSchedule.endedAt = null;
      });

      await scheduleList.updateSchedule(parentSchedule);
      await scheduleList.updateScheduleExecution(schedule);

      //await scheduleList.moveScheduleToHistory(schedule);
    }
    //nav.pop();
  }

  Future<bool> onPopOut() async {
    // await scheduleList.scheduleNotification(
    //     schedule, DateTime.now(), invokeCounter);
    if (schedule.scheduleStatus == statusDone) {
      //await scheduleList.resetActivities(schedule);
    } else {
      await scheduleList.scheduleNotificationForExecution(
        schedule,
        DateTime.now(),
      );
    }
    return true;
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      scheduleList = Provider.of<ScheduleList>(context, listen: false);
      // if (scheduleList.notificationCameForSchedule != null) {
      //   schedule = scheduleList.notificationCameForSchedule!;
      //   scheduleList.notificationCameForSchedule = null;
      // } else {
      Map<String, dynamic> schArg = scheduleList.notificationCameAs != null
          ? scheduleList.notificationCameAs!
          : ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      Schedule parentSchedule = scheduleList.schedules
          .firstWhere((sch) => sch.name == schArg[payLoadSchduleName]);
      schedule = parentSchedule.scheduleHistory.firstWhere(
          (schEx) => schEx.scheduleExecutionId == schArg[payLoadSchduleExecId]);
      //}
      activities = schedule.activities;
      if (schedule.scheduleStatus == statusExecuting &&
          !schedule.at!.isAfter(DateTime.now())) {
        updateWaitDuration();
      } else {
        invokeCounter = activities.length;
      }
      initializing = false;
      scheduleList.notificationCameAs = null;
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
                            : nav.pushNamed(ScheduleListScreen.routename);
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
