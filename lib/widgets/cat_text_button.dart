import 'package:flutter/material.dart';

class CatTextButton extends StatelessWidget {
  const CatTextButton({
    super.key,
    required this.buttonLabel,
    required this.buttonAction,
    required this.buttonIcon,
  });

  final String buttonLabel;
  final Function()? buttonAction;
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: buttonAction,
      style: ButtonStyle(
        iconColor: WidgetStateProperty.resolveWith(
          (states) => Theme.of(context).colorScheme.error,
        ),
      ),
      icon: Icon(
        buttonIcon,
      ),
      label: Text(
        buttonLabel,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
