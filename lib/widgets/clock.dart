import 'dart:async';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/widgets/clock_digit_widget.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    //double appWidth = MediaQuery.of(context).size.width - 16;
    return Container(
      //margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        //     gradient: RadialGradient(
        //       colors: [
        //         Theme.of(context).primaryColor,
        //         Theme.of(context).colorScheme.background,
        //       ],
        //     ),
        //     image: DecorationImage(
        //       opacity: 0.1,
        //       image: AssetImage(
        //         assetMap['logoImage']!,
        //       ),
        //       fit: BoxFit.contain,
        //     )
        //     // borderRadius: const BorderRadius.all(
        //     //   Radius.circular(20),
        //     // ),
      ),
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
                const Text(":"),
                ClockDigitWidget(
                  text: minute,
                ),
                const Text(":"),
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
    );
  }
}
