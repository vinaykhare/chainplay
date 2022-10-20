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
  String displaySeconds = "";

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
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
    const reduceSecondsBy = 1;
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

    displaySeconds = strDigits(myDuration.inSeconds.remainder(60));
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
                "Take Rest",
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
              CircleAvatar(
                radius: 100,
                child: Text(
                  displaySeconds,
                  style: Theme.of(context).textTheme.headline2,
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
