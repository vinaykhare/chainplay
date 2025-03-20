import 'dart:async';
import 'dart:io';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/helper_functions.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/models/system_setting.dart';

class PlayWaitActivityTutorial extends StatefulWidget {
  static String routename = "run_activity_tutorial";
  const PlayWaitActivityTutorial({super.key});
  @override
  State<PlayWaitActivityTutorial> createState() =>
      _PlayWaitActivityTutorialState();
}

class _PlayWaitActivityTutorialState extends State<PlayWaitActivityTutorial> {
  Timer? countdownTimer;
  List<SystemSetting> systemSettings = [];
  late Duration waitDuration, initialWaitDuration;
  DateTime? resumedAt;
  // late ChainList chainList;
  late ChainActivity chainActivity;
  bool initializing = true;
  bool running = true,
      showPlayPause = true,
      appSoundEnabled = true,
      speechPlayed = false;
  //isNotPlaying = false;
  String? screenImage, title;
  // String? textToSpeak;
  int playScreenType = waitActivityInDB;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   if (!speechPlayed && textToSpeak != null && textToSpeak!.isNotEmpty) {
  //     speak();
  //     speechPlayed = true;
  //   }
  // }

  @override
  void dispose() {
    if (countdownTimer != null) countdownTimer?.cancel();
    super.dispose();
  }

  // Future<void> speak() async {
  //   chainList = Provider.of<ChainList>(context, listen: false);
  //   isNotPlaying = chainList.isTtsPlaying();
  //   isNotPlaying = await chainList.stopSpeech();

  //   isNotPlaying = chainList.isTtsPlaying();
  //   isNotPlaying = await chainList.speakText(
  //     textToSpeak!,
  //   );
  //   isNotPlaying = chainList.isTtsPlaying();
  // }

  Future<void> setCountDown() async {
    final seconds = waitDuration.inSeconds - 1;
    // NavigatorState nav = Navigator.of(context);

    if (seconds == 1) {
      // FlutterRingtonePlayer.play(
      //     fromAsset: assetMap['beepAudio']!, ios: IosSounds.glass);
      await Provider.of<ChainList>(context, listen: false)
          .playNotificationSound();
    }

    if (seconds < 1) {
      stopTimer();
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
      playScreenType = input["playScreenType"];
      running = input["running"];
      screenImage = input["screenImage"];
      // textToSpeak = input["textToSpeak"];
      switch (playScreenType) {
        case systemWaitActivityInDB:
          title = "Rest";
          break;
        case systemEndActivityInDB:
          title = "Complete this Chain";
          break;
        default:
          title = chainActivity.activity.title;
      }
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
    final String displaySeconds = waitDuration.inSeconds <= 1
        ? "Done"
        : strDigits(waitDuration.inSeconds.remainder(60));
    // timeLeft = "$hours:$minutes:$displaySeconds";
    timeLeft = hours == 0 && minutes == 0 && seconds != 0
        ? " in "
        : HelperFunctions.durationToString(
            Duration(
              hours: hours,
              minutes: minutes,
            ),
          );
    //}
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;

    return IgnorePointer(
      ignoring: true,
      child: Semantics(
        label: "Play Timer Screen Tutorial",
        child: Scaffold(
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                key: KeyHelper.playWaitKey,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      child: screenImage == null || screenImage == ""
                          ? Image.asset(
                              assetMap['logoImage']!,
                              fit: BoxFit.fitHeight,
                              height: appHeight * 0.45,
                            )
                          : screenImage!.startsWith("http")
                              ? FadeInImage.assetNetwork(
                                  placeholder: assetMap["logoImage"]!,
                                  image: screenImage!,
                                  height: appHeight * 0.45,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                          Image.asset(
                                    assetMap['logoImage']!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.file(
                                  File(screenImage!),
                                  height: appHeight * 0.45,
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                  Text(
                    title ?? "Generic Activity",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (playScreenType != systemEndActivityInDB)
                    Text(
                      "will compelte\n$timeLeft\n${(hours != 0 || minutes != 0) && seconds != 0 ? 'and' : ''}",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    )
                  else
                    Text(
                      "by pressing done.",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  CircleAvatar(
                    key: KeyHelper.playWaitTimerKey,
                    radius: 50,
                    backgroundColor: playScreenType == systemWaitActivityInDB
                        ? Theme.of(context).focusColor
                        : Theme.of(context).canvasColor,
                    child: FittedBox(
                      child: Text(
                        displaySeconds,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  if (waitDuration.inSeconds != 0)
                    Text(
                      "Seconds.",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  if (waitDuration.inSeconds != 0)
                    ElevatedButton.icon(
                      key: KeyHelper.playWaitGoBackAndNotifyKey,
                      label: const Text("Go Back & Notify when done"),
                      onPressed: () {
                        Navigator.of(context).pop({
                          "running": false, //running,
                          "waitDuration": waitDuration,
                          "interruptAndCompleted": false,
                          "resumedAt": resumedAt,
                          "notify": true,
                        });
                      },
                      icon: Icon(
                        Icons.notification_add,
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).cardColor,
                    ),
                    child: const ShowBannerAd(),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Row(
              children: [
                Row(
                  key: KeyHelper.playWaitBackwardKey,
                  children: [
                    Icon(
                      Icons.arrow_back,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 5,
                      ),
                      child: const Text("Chain Status"),
                    ),
                  ],
                ),
                if (showPlayPause)
                  Expanded(
                    child: IconButton(
                      key: KeyHelper.playWaitPlayPauseKey,
                      onPressed: () {},
                      icon: Icon(
                        running ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: SizedBox(
                      height: 45,
                    ),
                  ),
                Row(
                  key: KeyHelper.playWaitForwardKey,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: 5,
                      ),
                      child: const Text(
                        "Next Activity",
                      ),
                    ),
                    Icon(
                      playScreenType == systemEndActivityInDB
                          ? Icons.done
                          : Icons.arrow_forward,
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
