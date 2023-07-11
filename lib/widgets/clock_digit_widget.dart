import 'package:flutter/material.dart';

class ClockDigitWidget extends StatelessWidget {
  final String text;
  const ClockDigitWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.displaySmall,
    );
  }
}
