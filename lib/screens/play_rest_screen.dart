import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class PlayRest extends StatefulWidget {
  static String routename = "play_rest";
  const PlayRest({super.key});
  @override
  State<PlayRest> createState() => _PlayRestState();
}

class _PlayRestState extends State<PlayRest> {
  Timer? countdownTimer;
  late Duration myDuration;
  //bool initParams = true;
  String displaySeconds = "";

  @override
  void dispose() {
    if (countdownTimer != null) countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myDuration = ModalRoute.of(context)?.settings.arguments as Duration;
    startTimer();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
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
    setState(() => myDuration = myDuration);
  }

  // Step 6
  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds == 0) {
        FlutterRingtonePlayer.playNotification();
      }
      if (seconds < 0) {
        if (countdownTimer != null) countdownTimer?.cancel();

        Navigator.of(context).pop();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    // if (initParams) {
    //   myDuration = ModalRoute.of(context)?.settings.arguments as Duration;
    //   startTimer();
    //   initParams = false;
    // }

    String timeLeft = "Rest Complete";

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
                "Take Rest",
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
              InkWell(
                onTap: () {
                  FlutterRingtonePlayer.playNotification();
                  stopTimer();
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  radius: 150,
                  child: FittedBox(
                    child: Text(
                      timeLeft,
                      style: Theme.of(context).textTheme.headline3,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
