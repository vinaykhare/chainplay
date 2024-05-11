import 'package:flutter/material.dart';

class ButtonPair extends StatelessWidget {
  const ButtonPair({
    super.key,
    required this.leftMethod,
    required this.rightMethod,
    required this.leftLabel,
    required this.rightLabel,
  });

  final VoidCallback leftMethod, rightMethod;
  final String leftLabel, rightLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: leftMethod,
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).cardColor,
              ),
              label: Text(
                leftLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: rightMethod,
              icon: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).cardColor,
              ),
              label: Text(
                rightLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
