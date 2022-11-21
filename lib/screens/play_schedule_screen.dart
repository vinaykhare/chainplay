import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/play_rest_screen.dart';

class PlaySchedule extends StatefulWidget {
  static String routename = "play_schedule";
  const PlaySchedule({super.key});
  @override
  State<PlaySchedule> createState() => _PlayScheduleState();
}

class _PlayScheduleState extends State<PlaySchedule> {
  Timer? countdownTimer;
  late Duration waitDuration;
  Duration waitDurationDifferenceForRestScreen = const Duration(seconds: 0);
  late Schedule schedule;
  late ScheduleList scheduleList;
  List<ScheduleActivity> activities = [];
  int invokeCounter = 0;
  bool exitPlaySchedule = false;
  bool initializing = true;

  @override
  void dispose() {
    super.dispose();
    if (countdownTimer != null) countdownTimer?.cancel();
  }

  void updateWaitDuration() async {
    Duration calculatedWaitDuration = const Duration(seconds: 0);
    Duration timeSpentSinceStartOfSchedule =
        DateTime.now().difference(schedule.at!);
    for (Duration appExecutedFor = const Duration(seconds: 0);
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
      if (activities[invokeCounter].endedAt == null) {
        activities[invokeCounter].endedAt = DateTime.now();
        await scheduleList.updateScheduleActivityByActivityId(
            schedule, activities[invokeCounter]);
      }
      //await scheduleList.loadActivities(schedule);
    }

    if (invokeCounter < schedule.activities.length) {
      setState(() {
        waitDuration = calculatedWaitDuration;
      });
    } else {
      exitPlaySchedule = true;
      waitDuration = const Duration(seconds: 0);
      // temp solution to skip failure on executing shcedule without activities (all done).
      invokeCounter--;
    }
  }

  Future<void> nextActivity() async {
    setState(() {});
    NavigatorState nav = Navigator.of(context);
    if (exitPlaySchedule) {
      schedule.at = null;
      schedule.scheduleStatus = statusDone;
      await scheduleList.updateSchedule(schedule);
      await scheduleList.updatScheduleActivityByScheduleName(schedule);
      nav.pop();
    } else if (activities[invokeCounter].activityDuration.inSeconds != 0 ||
        activities[invokeCounter].endedAt != null) {
      startTimer();
    }
  }

  Future<void> goToNextPage() async {
    NavigatorState nav = Navigator.of(context);

    activities[invokeCounter].endedAt = DateTime.now();
    await scheduleList.updateScheduleActivityByActivityId(
        schedule, activities[invokeCounter]);

    if (activities[invokeCounter].nextActivityAfter.inSeconds > 0) {
      var restScreenResponse = await nav.pushNamed(
        PlayRest.routename,
        arguments: waitDurationDifferenceForRestScreen.inSeconds != 0
            ? waitDurationDifferenceForRestScreen
            : activities[invokeCounter].nextActivityAfter,
      );
      if (restScreenResponse == null) {
        await scheduleList.scheduleNotification(
            schedule, DateTime.now(), invokeCounter);
        nav.pop();
      } else {
        await scheduleList.flipDoneActivity(
            schedule, activities[invokeCounter]);
      }
    } else {
      await scheduleList.flipDoneActivity(schedule, activities[invokeCounter]);
    }
    waitDurationDifferenceForRestScreen = const Duration(seconds: 0);
    invokeCounter++;
    if (invokeCounter < activities.length) {
      activities[invokeCounter].at = DateTime.now();
      await scheduleList.scheduleNotification(
        schedule,
        activities[invokeCounter].at!,
        invokeCounter,
      );
    }

    updateWaitDuration();
    nextActivity();
  }

  Future<void> setCountDown() async {
    final seconds = waitDuration.inSeconds - 1;

    if (seconds == 0) {
      // FlutterRingtonePlayer.play(
      //     fromAsset: "assets/ringtone.wav", ios: IosSounds.glass);
      FlutterRingtonePlayer.play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
      );
    }

    if (seconds < 0) {
      stopTimer();
      return goToNextPage();
    } else {
      setState(() {
        waitDuration = Duration(seconds: seconds);
      });
    }
  }

  // Generic Timer Functions
  String strDigits(int n) => n.toString().padLeft(2, '0');

  void startTimer() {
    countdownTimer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (_) => setCountDown(),
    );
  }

  void stopTimer() {
    setState(() {
      if (countdownTimer != null) countdownTimer?.cancel();
    });
  }

  void resetTimer() {
    stopTimer();
    setState(() => waitDuration = activities[invokeCounter].activityDuration);
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      scheduleList = Provider.of<ScheduleList>(context, listen: false);
      schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
      activities = schedule.activities.toList();
      updateWaitDuration();
      nextActivity();
      initializing = false;
    }
    String timeLeft = "Done";
    //if (waitDuration.inSeconds > 0) {
    final int hours = waitDuration.inHours.remainder(60);
    final int minutes = waitDuration.inMinutes.remainder(60);
    final int seconds = waitDuration.inSeconds.remainder(60);
    final String displaySeconds = waitDuration.inSeconds == 0
        ? "Done"
        : strDigits(waitDuration.inSeconds.remainder(60));
    // timeLeft = "$hours:$minutes:$displaySeconds";
    timeLeft = hours == 0 && minutes == 0 && seconds != 0
        ? " in "
        : TransformFunctions.durationToString(
            Duration(
              hours: hours,
              minutes: minutes,
            ),
          );
    //}
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 50),
          padding: const EdgeInsets.all(10),
          height: appHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                activities[invokeCounter].activity.title,
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
              Text(
                "will compelte\n$timeLeft\n${(hours != 0 || minutes != 0) && seconds != 0 ? 'and' : ''}",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
              InkWell(
                onTap: () async {
                  FlutterRingtonePlayer.playNotification();
                  stopTimer();
                  await goToNextPage();
                },
                child: CircleAvatar(
                  radius: 150,
                  child: FittedBox(
                    child: Text(
                      displaySeconds,
                      style: Theme.of(context).textTheme.headline1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (waitDuration.inSeconds != 0)
                Text(
                  "Seconds.",
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
