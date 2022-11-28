import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/schedule_activity.dart';

class PlayActivity extends StatefulWidget {
  static String routename = "run_activity";
  const PlayActivity({super.key});
  @override
  State<PlayActivity> createState() => _PlayActivityState();
}

class _PlayActivityState extends State<PlayActivity> {
  Timer? countdownTimer;
  late Duration waitDuration, initialWaitDuration;
  late ScheduleActivity scheduleActivity;
  bool initializing = true;
  bool running = true, showPlayPause = true;

  @override
  void dispose() {
    super.dispose();
    if (countdownTimer != null) countdownTimer?.cancel();
  }

  // void updateWaitDuration() async {
  //   Duration calculatedWaitDuration = const Duration(seconds: 0);
  //   Duration timeSpentSinceStartOfSchedule =
  //       DateTime.now().difference(schedule.at!);
  //   for (Duration appExecutedFor = const Duration(seconds: 0);
  //       invokeCounter < schedule.activities.length;
  //       invokeCounter++) {
  //     if (activities[invokeCounter].activityDone) {
  //       continue;
  //     }
  //     if (activities[invokeCounter].activityDuration.inSeconds == 0 &&
  //         activities[invokeCounter].endedAt == null) {
  //       break;
  //     }
  //     appExecutedFor += activities[invokeCounter].activityDuration;

  //     if (timeSpentSinceStartOfSchedule < appExecutedFor) {
  //       calculatedWaitDuration = appExecutedFor - timeSpentSinceStartOfSchedule;
  //       break;
  //     }

  //     appExecutedFor += activities[invokeCounter].nextActivityAfter;
  //     if (timeSpentSinceStartOfSchedule < appExecutedFor) {
  //       waitDurationDifferenceForRestScreen =
  //           appExecutedFor - timeSpentSinceStartOfSchedule;
  //       break;
  //     }
  //     if (activities[invokeCounter].endedAt == null) {
  //       activities[invokeCounter].endedAt = DateTime.now();
  //       await scheduleList.updateScheduleActivityByActivityId(
  //           schedule, activities[invokeCounter]);
  //     }
  //     //await scheduleList.loadActivities(schedule);
  //   }

  //   if (invokeCounter < schedule.activities.length) {
  //     setState(() {
  //       waitDuration = calculatedWaitDuration;
  //     });
  //   } else {
  //     exitPlayActivity = true;
  //     waitDuration = const Duration(seconds: 0);
  //     // temp solution to skip failure on executing shcedule without activities (all done).
  //     invokeCounter--;
  //   }
  // }

  // Future<void> nextActivity() async {
  //   setState(() {});
  //   NavigatorState nav = Navigator.of(context);
  //   if (exitPlayActivity) {
  //     schedule.at = null;
  //     schedule.scheduleStatus = statusDone;
  //     await scheduleList.updateSchedule(schedule);
  //     await scheduleList.updatScheduleActivityByScheduleName(schedule);
  //     nav.pop();
  //   } else if (activities[invokeCounter].activityDuration.inSeconds != 0 ||
  //       activities[invokeCounter].endedAt != null) {
  //     startTimer();
  //   }
  // }

  // Future<void> goToNextPage() async {
  //   NavigatorState nav = Navigator.of(context);

  //   activities[invokeCounter].endedAt = DateTime.now();
  //   await scheduleList.updateScheduleActivityByActivityId(
  //       schedule, activities[invokeCounter]);

  //   if (activities[invokeCounter].nextActivityAfter.inSeconds > 0) {
  //     var restScreenResponse = await nav.pushNamed(
  //       PlayRest.routename,
  //       arguments: waitDurationDifferenceForRestScreen.inSeconds != 0
  //           ? waitDurationDifferenceForRestScreen
  //           : activities[invokeCounter].nextActivityAfter,
  //     );
  //     if (restScreenResponse == null) {
  //       nav.pop();
  //     } else {
  //       await scheduleList.flipDoneActivity(
  //           schedule, activities[invokeCounter]);
  //     }
  //   } else {
  //     await scheduleList.flipDoneActivity(schedule, activities[invokeCounter]);
  //   }
  //   waitDurationDifferenceForRestScreen = const Duration(seconds: 0);
  //   invokeCounter++;
  //   if (invokeCounter < activities.length) {
  //     activities[invokeCounter].at = DateTime.now();
  //     await scheduleList.scheduleNotification(
  //       schedule,
  //       activities[invokeCounter].at!,
  //       invokeCounter,
  //     );
  //   }

  //   updateWaitDuration();
  //   nextActivity();
  // }

  Future<void> setCountDown() async {
    final seconds = waitDuration.inSeconds - 1;

    if (seconds == 0) {
      // FlutterRingtonePlayer.play(
      //     fromAsset: "assets/ringtone.wav", ios: IosSounds.glass);
      FlutterRingtonePlayer.play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
      );
    }

    if (seconds < 0) {
      stopTimer();
      Navigator.of(context).pop(1);
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
      // scheduleList = Provider.of<ScheduleList>(context, listen: false);
      // schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
      // activities = schedule.activities.toList();
      // updateWaitDuration();
      // nextActivity();
      Map<String, dynamic> input =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      initialWaitDuration = waitDuration = input["waitDuration"];
      scheduleActivity = input["scheduleActivity"];
      if (waitDuration.inSeconds > 0) {
        startTimer();
      } else {
        setState(() {
          showPlayPause = false;
          running = false;
        });
      }
      initializing = false;
    }
    String timeLeft = "Done";
    //if (waitDuration.inSeconds > 0) {
    final int hours = waitDuration.inHours.remainder(60);
    final int minutes = waitDuration.inMinutes.remainder(60);
    final int seconds = waitDuration.inSeconds.remainder(60);
    final String displaySeconds = waitDuration.inSeconds == 0
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
        50;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 50),
            padding: const EdgeInsets.all(10),
            height: appHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  scheduleActivity.activity.title,
                  style: Theme.of(context).textTheme.headline2,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "will compelte\n$timeLeft\n${(hours != 0 || minutes != 0) && seconds != 0 ? 'and' : ''}",
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
                InkWell(
                  onTap: () async {
                    FlutterRingtonePlayer.playNotification();
                    stopTimer();
                    Navigator.of(context).pop(1);
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
                if (waitDuration.inSeconds != 0)
                  Text(
                    "Seconds.",
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: () {
                        FlutterRingtonePlayer.playNotification();
                        stopTimer();
                        Navigator.of(context).pop(1);
                      },
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
