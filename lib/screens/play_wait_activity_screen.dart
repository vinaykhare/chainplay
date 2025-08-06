import 'dart:async';
import 'dart:io';

import 'package:chain_activities/helpers/common_logic.dart';
import 'package:chain_activities/helpers/common_ui.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/notification_helper.dart';
import 'package:chain_activities/widgets/cat_button.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/content_transformer.dart';
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
      speechPlayed = false,
      orientationLandScape = false;
  //isNotPlaying = false;
  String? screenImage, title;
  // String? textToSpeak;
  int playScreenType = waitActivityInDB;

  @override
  void dispose() {
    super.dispose();
    if (countdownTimer != null) countdownTimer?.cancel();
  }

  Future<void> setOrietation(bool isLandscape) async {
    await CommonLogic().setOrietation(isLandscape);
    orientationLandScape = isLandscape;
  }

  Future<void> setCountDown() async {
    final seconds = waitDuration.inSeconds - 1;
    NavigatorState nav = Navigator.of(context);
    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    if (chainList.notificationHelper.isAppSoundEnabled()) {
      if (seconds == 3) {
        await chainList.speakTextWithoutWait("3");
      } else if (seconds == 2) {
        await chainList.speakTextWithoutWait("2");
      } else if (seconds == 1) {
        await chainList.speakTextWithoutWait("1");
        await chainList.playNotificationSound();
      }
    } else {
      if (seconds == 1) {
        await chainList.playNotificationSound();
      }
    }

    if (seconds < 1) {
      stopTimer();
      nav.pop({
        "orientationLandScape": orientationLandScape,
        "completionMessage": chainActivityCompletionMessageDone,
      });
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

  Future<void> interruptAndCompleteActivity() async {
    NavigatorState nav = Navigator.of(context);
    await Provider.of<ChainList>(context, listen: false)
        .playNotificationSound();
    stopTimer();
    nav.pop(waitDuration.inSeconds <= 0
        ? {
            "orientationLandScape": orientationLandScape,
            "completionMessage": chainActivityCompletionMessageDone,
          }
        : {
            "running": running,
            "waitDuration": waitDuration,
            "interruptAndCompleted": true,
            "resumedAt": resumedAt,
            "completionMessage": chainActivityCompletionMessageDone,
            "orientationLandScape": orientationLandScape,
          });
  }

  Future<void> completeTheChain(String completionMessage,
      [DateTime? chainStartTime]) async {
    NavigatorState nav = Navigator.of(context);
    await Provider.of<ChainList>(context, listen: false)
        .playNotificationSound();
    nav.pop({
      "completionMessage": completionMessage,
      "orientationLandScape": orientationLandScape,
      "nextChainStartTime": chainStartTime,
    });
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      Map<String, dynamic> input =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      initialWaitDuration = waitDuration = input["waitDuration"];
      chainActivity = input["chainActivity"];
      playScreenType = input["playScreenType"];
      running = input["running"];
      screenImage = input["screenImage"];
      orientationLandScape = input["orientationLandScape"] ?? false;

      setOrietation(orientationLandScape);
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
    String timeLeft = chainActivityCompletionMessageDone;
    //if (waitDuration.inSeconds > 0) {
    final int hours = waitDuration.inHours.remainder(60);
    final int minutes = waitDuration.inMinutes.remainder(60);
    final int seconds = waitDuration.inSeconds.remainder(60);
    final String displaySeconds = waitDuration.inSeconds <= 1
        ? chainActivityCompletionMessageDone
        : strDigits(waitDuration.inSeconds.remainder(60));
    // timeLeft = "$hours:$minutes:$displaySeconds";
    timeLeft = hours == 0 && minutes == 0 && seconds != 0
        ? " in "
        : ContentTransformer.durationToString(
            Duration(
              hours: hours,
              minutes: minutes,
            ),
          );
    //}
    // double appHeight = MediaQuery.of(context).size.height -
    //     MediaQuery.of(context).viewPadding.top -
    //     MediaQuery.of(context).viewPadding.bottom;

    double appWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Semantics(
        label: "Play Timer Screen",
        child: Scaffold(
          body: SafeArea(
            child: OrientationBuilder(builder: (context, orientation) {
              Widget activityContent = SingleChildScrollView(
                child: Column(
                  children: [
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CatButton(
                                  buttonLabel: "Restart this Chain",
                                  buttonIcon: Icons.restart_alt,
                                  buttonAction: () async {
                                    await completeTheChain(
                                        chainActivityCompletionMessageRestart);
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CatButton(
                                  buttonLabel: "Start it a Little Later",
                                  buttonIcon: Icons.schedule,
                                  buttonAction: () async {
                                    ScaffoldMessengerState scms =
                                        ScaffoldMessenger.of(context);

                                    DateTime? chainStartTime;
                                    chainStartTime =
                                        await CommonUI().getDateTimeDialog(
                                      context,
                                      chainStartTime,
                                    );
                                    if (chainStartTime == null) {
                                      return;
                                    }
                                    if (chainStartTime
                                        .isBefore(DateTime.now())) {
                                      chainStartTime = null;
                                      return;
                                    }

                                    bool permissionGranted =
                                        await NotificationHelper()
                                            .localNotificationService
                                            .askNotificationPermission();
                                    if (permissionGranted) {
                                      await completeTheChain(
                                        chainActivityCompletionMessageRestart,
                                        chainStartTime,
                                      );
                                    } else {
                                      scms.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please allow notification permission to schedule the next activity.",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CatButton(
                                  buttonLabel: "Done for now",
                                  buttonIcon: Icons.done,
                                  buttonAction: interruptAndCompleteActivity,
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
                    if (waitDuration.inSeconds != 0)
                      ElevatedButton.icon(
                        label: const Text("Go Back & Notify when done"),
                        onPressed: () {
                          Navigator.of(context).pop({
                            "running": false, //running,
                            "waitDuration": waitDuration,
                            "interruptAndCompleted": false,
                            "resumedAt": resumedAt,
                            "notify": true,
                            "orientationLandScape": orientationLandScape,
                            "completionMessage": null,
                          });
                        },
                        icon: Icon(
                          Icons.notification_add,
                        ),
                      ),
                    if (orientation == Orientation.portrait)
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
              );
              Widget activityImage = Container(
                margin: const EdgeInsets.all(5),
                width: appWidth,
                child: Stack(
                  children: [
                    Center(
                      child: screenImage == null || screenImage == ""
                          ? Image.asset(
                              assetMap['logoImage']!,
                              // fit: BoxFit.fitHeight,
                              //height: appHeight * 0.45,
                            )
                          : screenImage!.startsWith("http")
                              ? FadeInImage.assetNetwork(
                                  placeholder: assetMap["logoImage"]!,
                                  image: screenImage!,
                                  // height: appHeight * 0.45,
                                  //fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                          Image.asset(
                                    assetMap['logoImage']!,
                                    // fit: BoxFit.cover,
                                  ),
                                )
                              : Image.file(
                                  File(screenImage!),
                                  // height: appHeight * 0.45,
                                  // fit: BoxFit.fitWidth,
                                ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                        icon: Icon(
                          Icons.screen_rotation,
                        ),
                        onPressed: () {
                          setState(() {
                            setOrietation(!orientationLandScape);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
              return orientation == Orientation.landscape
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: activityImage,
                        ),
                        if (playScreenType != systemEndActivityInDB)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: appWidth * 0.05),
                            child: activityContent,
                          )
                        else
                          Expanded(
                            child: activityContent,
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: activityImage),
                        activityContent,
                      ],
                    );
            }),
          ),
          bottomNavigationBar: SafeArea(
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop({
                      "running": false, //running,
                      "waitDuration": waitDuration,
                      "interruptAndCompleted": false,
                      "resumedAt": resumedAt,
                      "orientationLandScape": orientationLandScape,
                      "completionMessage": chainActivityCompletionMessageDone,
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timeline,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 5,
                        ),
                        child: const Text("Chain Status"),
                      ),
                    ],
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
                    child: SizedBox(
                      height: 45,
                    ),
                  ),
                InkWell(
                  onTap: interruptAndCompleteActivity,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Text(
                          playScreenType == systemEndActivityInDB
                              ? "Complete"
                              : "Next Activity",
                        ),
                      ),
                      Icon(
                        playScreenType == systemEndActivityInDB
                            ? Icons.done
                            : Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
