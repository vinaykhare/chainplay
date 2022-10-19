import 'dart:async';

import 'package:flutter/material.dart';

class PlayRest extends StatefulWidget {
  static String routename = "play_rest";
  const PlayRest({super.key});
  @override
  State<PlayRest> createState() => _PlayRestState();
}

class _PlayRestState extends State<PlayRest> {
  Timer? countdownTimer;
  late Duration myDuration;
  bool initParams = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  // Step 4
  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  // Step 5
  void resetTimer() {
    stopTimer();
    setState(() => myDuration = myDuration);
  }

  // Step 6
  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
        Navigator.of(context).pop();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (initParams) {
      myDuration = ModalRoute.of(context)?.settings.arguments as Duration;
      initParams = false;
    }

    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rest"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$seconds"),
          TextButton(
            onPressed: startTimer,
            child: const Text("Start Timer"),
          ),
          TextButton(
            onPressed: stopTimer,
            child: const Text("Stop Timer"),
          ),
          TextButton(
            onPressed: resetTimer,
            child: const Text("Reset Timer"),
          ),
        ],
      ),
    );
  }
}
