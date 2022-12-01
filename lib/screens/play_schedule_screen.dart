import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/play_activity_screen.dart';
import 'package:schedule_it/widgets/schedule_activities.dart';

class PlaySchedule extends StatefulWidget {
  static String routename = "play_schedule";
  const PlaySchedule({super.key});
  @override
  State<PlaySchedule> createState() => _PlayScheduleState();
}

class _PlayScheduleState extends State<PlaySchedule> {
  Duration waitDurationDifferenceForRestScreen = const Duration(seconds: 0);
  late Schedule schedule;
  late ScheduleList scheduleList;
  List<ScheduleActivity> activities = [];
  int invokeCounter = 0;
  bool initializing = true;

  void updateWaitDuration() async {
    dynamic popResponse;
    NavigatorState nav = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 1));
    Duration calculatedWaitDuration = const Duration(seconds: 0);
    Duration timeSpentSinceStartOfSchedule =
        DateTime.now().difference(schedule.at!);
    for (Duration appExecutedFor = calculatedWaitDuration;
        invokeCounter < schedule.activities.length;
        invokeCounter++) {
      if (activities[invokeCounter].activityDone) {
        continue;
      }
      if (activities[invokeCounter].activityDuration.inSeconds == 0 &&
          activities[invokeCounter].endedAt == null) {
        break;
      }
      appExecutedFor += activities[invokeCounter].activityDuration;

      if (timeSpentSinceStartOfSchedule < appExecutedFor) {
        calculatedWaitDuration = appExecutedFor - timeSpentSinceStartOfSchedule;
        break;
      }

      appExecutedFor += activities[invokeCounter].nextActivityAfter;
      if (timeSpentSinceStartOfSchedule < appExecutedFor) {
        waitDurationDifferenceForRestScreen =
            appExecutedFor - timeSpentSinceStartOfSchedule;
        break;
      }

      activities[invokeCounter].endedAt = schedule.at!.add(appExecutedFor);
      activities[invokeCounter].activityDone = true;
      await scheduleList.updateScheduleActivityByActivityId(
          schedule, activities[invokeCounter]);

      //await scheduleList.loadActivities(schedule);
    }

    for (; invokeCounter < schedule.activities.length; invokeCounter++) {
      activities[invokeCounter].at = DateTime.now();
      // await scheduleList.scheduleNotification(
      //   schedule,
      //   activities[invokeCounter].at!,
      //   invokeCounter,
      // );

      popResponse = await nav.pushNamed(
        PlayActivity.routename,
        arguments: {
          "waitDuration": calculatedWaitDuration.inSeconds != 0
              ? calculatedWaitDuration
              : activities[invokeCounter].activityDuration,
          "scheduleActivity": activities[invokeCounter],
          "playRest": false,
        },
      );
      if (popResponse == null) {
        break;
      }
      activities[invokeCounter].endedAt = DateTime.now();
      await scheduleList.updateScheduleActivityByActivityId(
          schedule, activities[invokeCounter]);

      calculatedWaitDuration = const Duration(seconds: 0);

      if (activities[invokeCounter].nextActivityAfter.inSeconds > 0) {
        //var restScreenResponse =
        // popResponse = await nav.pushNamed(
        //   PlayRest.routename,
        //   arguments: waitDurationDifferenceForRestScreen.inSeconds != 0
        //       ? waitDurationDifferenceForRestScreen
        //       : activities[invokeCounter].nextActivityAfter,
        // );

        popResponse = await nav.pushNamed(
          PlayActivity.routename,
          arguments: {
            "waitDuration": waitDurationDifferenceForRestScreen.inSeconds != 0
                ? waitDurationDifferenceForRestScreen
                : activities[invokeCounter].nextActivityAfter,
            "scheduleActivity": activities[invokeCounter],
            "playRest": true,
          },
        );

        if (popResponse == null) {
          break;
        }

        await Future.delayed(const Duration(seconds: 1));
        //}
      }
      await scheduleList.flipDoneActivity(schedule, activities[invokeCounter]);
      waitDurationDifferenceForRestScreen = const Duration(seconds: 0);
    }
    if (popResponse == null) {
      await scheduleList.scheduleNotification(
          schedule, DateTime.now(), invokeCounter);
    } else {
      schedule.at = null;
      schedule.scheduleStatus = statusDone;
      await scheduleList.updateSchedule(schedule);
      await scheduleList.updatScheduleActivityByScheduleName(schedule);
    }
    //nav.pop();
  }

  Future<bool> onPopOut() async {
    // await scheduleList.scheduleNotification(
    //     schedule, DateTime.now(), invokeCounter);
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
        updateWaitDuration();
      }
      initializing = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return WillPopScope(
      onWillPop: onPopOut,
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
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            floatingLabelAlignment:
                                FloatingLabelAlignment.center,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          initialValue: schedule.name,
                          enabled: false,
                        ),
                      ),
                      IconButton(
                        onPressed: schedule.scheduleStatus == statusDone
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
      ),
    );
  }
}
