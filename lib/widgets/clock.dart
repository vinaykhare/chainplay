import 'dart:async';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/widgets/clock_digit_widget.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  Timer? countdownTimer;
  String hour = "00", minute = "00", second = "00";

  @override
  void initState() {
    super.initState();
    countdownTimer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (_) {
        setState(() {
          hour = DateTime.now().hour.toString().padLeft(2, '0');
          minute = DateTime.now().minute.toString().padLeft(2, '0');
          second = DateTime.now().second.toString().padLeft(2, '0');
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
    Chain chain = Chain();
    chain.title =
        "System_Alarm_${Provider.of<ChainList>(context, listen: false).chains.length + 1}";
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
    await Provider.of<ChainList>(context, listen: false).addChain(
      chain,
      startChainActivity,
    );
    nav.pushNamed(AddChainScreen.routename, arguments: chain);
  }

  @override
  Widget build(BuildContext context) {
    //double appWidth = MediaQuery.of(context).size.width - 16;
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: InkWell(
        onTap: addAlarmChain,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "C A T",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClockDigitWidget(
                    text: hour,
                  ),
                  Text(
                    ":",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  ClockDigitWidget(
                    text: minute,
                  ),
                  Text(
                    ":",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  ClockDigitWidget(
                    text: second,
                  ),
                ],
              ),
            ),
            Text(
              DateFormat.yMEd().format(
                DateTime.now(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
