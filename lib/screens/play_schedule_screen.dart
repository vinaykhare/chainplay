import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
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
  int invokeCounter = 0;
  bool initializing = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    countdownTimer!.cancel();
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
    setState(() => countdownTimer!.cancel());
  }

  // Step 5
  void resetTimer() {
    stopTimer();
    setState(
        () => myDuration = schedule.activities[invokeCounter].activityDuration);
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
        // setState(() {
        //   invokeCounter++;
        //   myDuration = const Duration(seconds: 0);
        // });
        // await Navigator.of(context).pushNamed(PlayRest.routename,
        //     arguments: schedule.activities[invokeCounter].restDurationAfter);

        // myDuration = schedule.activities[invokeCounter].activityDuration;
        // startTimer();
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
      arguments: schedule.activities[invokeCounter].nextActivityAfter,
    );

    setState(() {
      if (invokeCounter + 1 < schedule.activities.length) {
        invokeCounter++;
        myDuration = schedule.activities[invokeCounter].activityDuration;
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
      //invokeCounter++;
      myDuration = schedule.activities[invokeCounter].activityDuration;

      initializing = false;
    }
    String timeLeft = "Done";
    if (myDuration.inSeconds > 0) {
      final String displayHours = strDigits(myDuration.inHours.remainder(60));
      final String displayMinutes =
          strDigits(myDuration.inMinutes.remainder(60));
      final String displaySeconds =
          strDigits(myDuration.inSeconds.remainder(60));
      timeLeft = "$displayHours:$displayMinutes:$displaySeconds";
    }
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
                schedule.activities[invokeCounter].title,
                style: Theme.of(context).textTheme.headline2,
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
                      timeLeft,
                      style: Theme.of(context).textTheme.headline2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (schedule
                      .activities[invokeCounter].activityDuration.inSeconds !=
                  0)
                Card(
                  elevation: 10,
                  child: Text(
                    "For \n${schedule.activities[invokeCounter].activityDuration.inSeconds} \nSeconds",
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
