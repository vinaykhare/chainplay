import 'package:flutter/material.dart';

class CatIconButton extends StatelessWidget {
  const CatIconButton({
    super.key,
    required this.buttonAction,
    required this.buttonIcon,
  });

  final Function() buttonAction;
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: buttonAction,
          style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith(
              (states) => Theme.of(context).colorScheme.error,
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => Theme.of(context).colorScheme.primary,
            ),
          ),
          icon: Icon(
            buttonIcon,
          ),
        ),
      ],
    );
  }
}
