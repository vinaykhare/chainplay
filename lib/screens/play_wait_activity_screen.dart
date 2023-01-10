import 'dart:async';
import 'dart:io';

import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/notification_helper.dart';
import 'package:chain_activities/helpers/transform_functions.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/models/system_setting.dart';

class PlayWaitActivity extends StatefulWidget {
  static String routename = "run_activity";
  const PlayWaitActivity({super.key});
  @override
  State<PlayWaitActivity> createState() => _PlayWaitActivityState();
}

class _PlayWaitActivityState extends State<PlayWaitActivity> {
  Timer? countdownTimer;
  List<SystemSetting> systemSettings = [];
  late Duration waitDuration, initialWaitDuration;
  DateTime? resumedAt;
  late ChainActivity chainActivity;
  bool initializing = true;
  bool running = true,
      showPlayPause = true,
      appSoundEnabled = true,
      playingRest = false;
  String? screenImage;
  NotificationHelper notificationHelper = NotificationHelper();

  @override
  void dispose() {
    super.dispose();
    if (countdownTimer != null) countdownTimer?.cancel();
  }

  Future<void> setCountDown() async {
    final seconds = waitDuration.inSeconds - 1;
    NavigatorState nav = Navigator.of(context);

    if (seconds == 1) {
      // FlutterRingtonePlayer.play(
      //     fromAsset: assetMap['beepAudio']!, ios: IosSounds.glass);
      await Provider.of<ChainList>(context, listen: false)
          .playNotificationSound();
    }

    if (seconds < 1) {
      stopTimer();
      nav.pop();
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
    setState(() => waitDuration = initialWaitDuration);
  }

  void interruptAndCompleteActivity() async {
    NavigatorState nav = Navigator.of(context);
    await Provider.of<ChainList>(context, listen: false)
        .playNotificationSound();
    stopTimer();
    nav.pop(waitDuration.inSeconds <= 0
        ? null
        : {
            "running": running,
            "waitDuration": waitDuration,
            "interruptAndCompleted": true,
            "resumedAt": resumedAt,
          });
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      // systemSettings =
      //     Provider.of<ChainList>(context, listen: false).systemSettings;
      // SystemSetting appSoundSetting =
      //     systemSettings.firstWhere((set) => set.key == appSoundSettingKey);
      // appSoundEnabled = appSoundSetting.value == trueSettingValue;
      // chain = ModalRoute.of(context)?.settings.arguments as Chain;
      // activities = chain.activities.toList();
      // updateWaitDuration();
      // nextActivity();
      Map<String, dynamic> input =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      initialWaitDuration = waitDuration = input["waitDuration"];
      chainActivity = input["chainActivity"];
      playingRest = input["playRest"];
      running = input["running"];
      screenImage = input["screenImage"];
      if (running && (waitDuration.inSeconds > 0)) {
        startTimer();
      }
      if (waitDuration.inSeconds <= 0) {
        setState(() {
          showPlayPause = false;
        });
      }
      initializing = false;
    }
    String timeLeft = "Done";
    //if (waitDuration.inSeconds > 0) {
    final int hours = waitDuration.inHours.remainder(60);
    final int minutes = waitDuration.inMinutes.remainder(60);
    final int seconds = waitDuration.inSeconds.remainder(60);
    final String displaySeconds = waitDuration.inSeconds == 1
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    child: screenImage == null || screenImage == ""
                        ? Image.asset(
                            assetMap['logoImage']!,
                            fit: BoxFit.cover,
                          )
                        : screenImage!.startsWith("http")
                            ? Image.network(
                                screenImage!,
                                height: 250,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(screenImage!),
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                Text(
                  playingRest ? "Rest" : chainActivity.activity.title,
                  style: Theme.of(context).textTheme.headline4,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "will compelte\n$timeLeft\n${(hours != 0 || minutes != 0) && seconds != 0 ? 'and' : ''}",
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                InkWell(
                  onTap: interruptAndCompleteActivity,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: playingRest
                        ? Theme.of(context).focusColor
                        : Theme.of(context).canvasColor,
                    child: FittedBox(
                      child: Text(
                        displaySeconds,
                        style: Theme.of(context).textTheme.headline4,
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
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          "running": running,
                          "waitDuration": waitDuration,
                          "interruptAndCompleted": false,
                          "resumedAt": resumedAt,
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    if (showPlayPause)
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            if (running) {
                              stopTimer();
                            } else {
                              startTimer();
                              resumedAt = DateTime.now();
                            }

                            setState(() {
                              running = !running;
                            });
                          },
                          icon: Icon(
                            running ? Icons.stop : Icons.pause,
                          ),
                        ),
                      )
                    else
                      const Expanded(
                        child: SizedBox(),
                      ),
                    IconButton(
                      onPressed: interruptAndCompleteActivity,
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
