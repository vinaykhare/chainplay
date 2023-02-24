import 'package:flutter/material.dart';

class ClockDigitWidget extends StatelessWidget {
  final String text;
  const ClockDigitWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(colors: [
          Theme.of(context).colorScheme.inversePrimary,
          Theme.of(context).colorScheme.primary,
        ])),
        child: TextFormField(
          enabled: false,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            //border: const OutlineInputBorder(),
            label: Center(
              child: Text(text),
            ),
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
