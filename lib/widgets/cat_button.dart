import 'package:flutter/material.dart';

class CatButton extends StatelessWidget {
  final Function() buttonAction;
  final IconData buttonIcon;
  final String buttonLabel;
  const CatButton({
    super.key,
    required this.buttonAction,
    required this.buttonIcon,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          //BoxShadow(color: Theme.of(context).primaryColor, spreadRadius: 5),
          BoxShadow(
            color: Theme.of(context).cardColor,
            spreadRadius: 5,
            blurRadius: 2,
            offset: Offset.infinite,
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: TextButton.icon(
        icon: Icon(
          buttonIcon,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        label: Text(
          buttonLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        onPressed: buttonAction,
      ),
    );
  }
}
