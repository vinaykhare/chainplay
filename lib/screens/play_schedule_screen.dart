import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/screens/play_rest_screen.dart';

class PlaySchedule extends StatefulWidget {
  static String routename = "play_schedule";
  const PlaySchedule({super.key});
  @override
  State<PlaySchedule> createState() => _PlayScheduleState();
}

class _PlayScheduleState extends State<PlaySchedule> {
  Timer? countdownTimer;
  late Duration myDuration;
  late Schedule schedule;
  List<Activity> activities = [];
  int invokeCounter = 0;
  bool initializing = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (countdownTimer != null) countdownTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (_) => setCountDown(),
    );
  }

  // Step 4
  void stopTimer() {
    setState(() {
      if (countdownTimer != null) countdownTimer?.cancel();
    });
  }

  // Step 5
  void resetTimer() {
    stopTimer();
    setState(() => myDuration = activities[invokeCounter].activityDuration);
  }

  // Step 6
  void setCountDown() async {
    const reduceSecondsBy = 1;
    final seconds = myDuration.inSeconds - reduceSecondsBy;

    if (invokeCounter > schedule.activities.length) {
      //stopTimer();
      Navigator.of(context).pop();
    }

    if (seconds == 0) {
      FlutterRingtonePlayer.playNotification();
    }

    if (seconds < 0) {
      stopTimer();
      if (invokeCounter + 1 == schedule.activities.length) {
        Navigator.of(context).pop();
      } else {
        goToRestPage();
      }
    } else {
      setState(() {
        myDuration = Duration(seconds: seconds);
      });
    }
  }

  void goToRestPage() async {
    // setState(() {
    //   myDuration = const Duration(seconds: 0);
    // });
    await Navigator.of(context).pushNamed(
      PlayRest.routename,
      arguments: activities[invokeCounter].nextActivityAfter,
    );

    setState(() {
      if (invokeCounter + 1 < schedule.activities.length) {
        invokeCounter++;
        myDuration = activities[invokeCounter].activityDuration;
      } else {
        Navigator.of(context).pop();
      }
    });

    if (myDuration.inSeconds != 0) {
      startTimer();
    }
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    //if (invokeCounter == 0) {
    if (initializing) {
      schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
      activities = schedule.activities.reversed.toList();
      //invokeCounter++;
      myDuration = activities[invokeCounter].activityDuration;
      if (myDuration.inSeconds != 0) {
        startTimer();
      }
      initializing = false;
    }
    String timeLeft = "Done";
    //if (myDuration.inSeconds > 0) {
    final int hours = myDuration.inHours.remainder(60);
    final int minutes = myDuration.inMinutes.remainder(60);
    final int seconds = myDuration.inSeconds.remainder(60);
    final String displaySeconds = myDuration.inSeconds == 0
        ? "Done"
        : strDigits(myDuration.inSeconds.remainder(60));
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
                activities[invokeCounter].title,
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
              Text(
                "will compelte\n$timeLeft\n${(hours != 0 || minutes != 0) && seconds != 0 ? 'and' : ''}",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
              InkWell(
                onTap: () {
                  FlutterRingtonePlayer.playNotification();
                  stopTimer();
                  goToRestPage();
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
              if (myDuration.inSeconds != 0)
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
