import 'dart:async';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/settings_screen.dart';
import 'package:chain_activities/widgets/clock_digit_widget.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Clock extends StatefulWidget {
  const Clock({
    super.key,
  });

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  Timer? countdownTimer;
  //String hour = "00", minute = "00", second = "00", ampm = "AM";
  late ChainList chainList;
  String catClockMode = "", time = "";

  @override
  void initState() {
    super.initState();
    chainList = Provider.of<ChainList>(context, listen: false);
    catClockMode =
        chainList.getSettingByKey(catClockModeKey).value.split(",")[0];
    time = chainList.getFormattedTimeBySetting(catClockMode);
    countdownTimer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (_) {
        setState(() {
          // hour = DateTime.now().hour.toString().padLeft(2, '0');
          // minute = DateTime.now().minute.toString().padLeft(2, '0');
          // second = DateTime.now().second.toString().padLeft(2, '0');
          // ampm = DateTime.now().hour <= 12 ? "AM" : "PM";
          time = chainList.getFormattedTimeBySetting(catClockMode);
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (countdownTimer != null) countdownTimer?.cancel();
  }

  Future<void> addAlarmChain() async {
    NavigatorState nav = Navigator.of(context);
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    if (!chainList.notificationHelper.eventNotificationsEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enable "$eventNotificationsKey" in Settings.'),
          duration: const Duration(
            seconds: 5,
          ),
          action: SnackBarAction(
              label: "Settings",
              onPressed: () {
                nav.pushReplacementNamed(SettingsScreen.routename);
              }),
        ),
      );
      return;
    }
    Chain chain = Chain();
    chain.title =
        "Alarm added on ${DateFormat.yMd().add_Hms().format(DateTime.now())}";
    //"Alarm ${Provider.of<ChainList>(context, listen: false).chains.length + 1}";
    chain.repeatType = repeatTypeDaily;
    ChainActivity startChainActivity = ChainActivity(
      activity: Activity(
        activityId: const Uuid().v1(),
        title: systemStartActivityInTitle,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
        type: systemStartActivityInDB,
      ),
    );
    startChainActivity.index = 0;
    chain.activities.add(
      startChainActivity,
    );
    await chainList.addChain(
      chain,
      startChainActivity,
    );
    nav.pushNamed(AddChainScreen.routename, arguments: chain);
  }

  @override
  Widget build(BuildContext context) {
    //double appWidth = MediaQuery.of(context).size.width - 16;

    // switch (catClockMode) {
    //   case "HH:MM:SS":
    //     time = DateFormat('kk:mm:ss').format(DateTime.now());
    //     break;
    //   case "HH:MM":
    //     time = DateFormat('kk:mm').format(DateTime.now());
    //     break;
    //   case "AM/PM":
    //     time = DateFormat.jm().format(DateTime.now());
    //     break;
    // }
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).secondaryHeaderColor,
            ],
          )),
      child: InkWell(
        onTap: addAlarmChain,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat.yMMMEd().format(
                DateTime.now(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const VerticalDivider(),
            ClockDigitWidget(
              text: time,
            ),
          ],
        ),
      ),
    );
  }
}
