import 'dart:async';
import 'dart:io';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/widgets/cat_button.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/helper_functions.dart';
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
            "completionMessage": null,
          });
  }

  Future<void> completeTheChain(String completionMessage) async {
    NavigatorState nav = Navigator.of(context);
    await Provider.of<ChainList>(context, listen: false)
        .playNotificationSound();
    nav.pop({
      "completionMessage": completionMessage,
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
      playScreenType = input["playScreenType"];
      running = input["running"];
      screenImage = input["screenImage"];
      // textToSpeak = input["textToSpeak"];
      switch (playScreenType) {
        case systemWaitActivityInDB:
          title = "Rest";
          break;
        case systemEndActivityInDB:
          title = "Congratulations";
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

    return Semantics(
      label: "Play Timer Screen",
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
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
                    ),
                  if (playScreenType != systemEndActivityInDB)
                    InkWell(
                      onTap: interruptAndCompleteActivity,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            playScreenType == systemWaitActivityInDB
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
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CatButton(
                                title: "Restart this Chian",
                                iconWidget: Icon(
                                  Icons.restart_alt,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                onPressedAction: () async {
                                  await completeTheChain(
                                    chainCompletionMessageRestart,
                                  );
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CatButton(
                                title: "Just Mark it Complete",
                                iconWidget: Icon(
                                  Icons.done,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                onPressedAction: interruptAndCompleteActivity,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (waitDuration.inSeconds != 0)
                    Text(
                      "Seconds.",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop({
                            "running": false, //running,
                            "waitDuration": waitDuration,
                            "interruptAndCompleted": false,
                            "resumedAt": resumedAt,
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
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
                              running ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                        )
                      else
                        const Expanded(
                          child: SizedBox(),
                        ),
                      IconButton(
                        onPressed: interruptAndCompleteActivity,
                        icon: Icon(
                          playScreenType == systemEndActivityInDB
                              ? Icons.done
                              : Icons.arrow_forward,
                        ),
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
