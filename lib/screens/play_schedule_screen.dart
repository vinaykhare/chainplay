import 'dart:async';

import 'package:flutter/material.dart';
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
      Duration(
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
    setState(() => myDuration = schedule.activityDuration);
  }

  // Step 6
  void setCountDown() async {
    final reduceSecondsBy = 1;
    final seconds = myDuration.inSeconds - reduceSecondsBy;

    if (seconds <= 0) {
      resetTimer();
      await Navigator.of(context)
          .pushNamed(PlayRest.routename, arguments: schedule.repeatAfter);
      startTimer();
      setState(() {
        invokeCounter++;
      });
    } else {
      setState(() {
        myDuration = Duration(seconds: seconds);
      });
    }

    if (invokeCounter > schedule.noOfRepeat) {
      stopTimer();
      Navigator.of(context).pop();
    }
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (invokeCounter == 0) {
      schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
      print("build wala");
      myDuration = schedule.activityDuration;
      invokeCounter++;
    }

    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Running Schedule"),
          Text("Scheudle Repeat Total: ${schedule.noOfRepeat}"),
          Text("$seconds"),
          Text(
              "Scheudle Repeatation: ${invokeCounter < schedule.noOfRepeat ? invokeCounter : schedule.noOfRepeat}"),
          IconButton(onPressed: stopTimer, icon: const Icon(Icons.stop)),
        ],
      ),
    );
  }
}
