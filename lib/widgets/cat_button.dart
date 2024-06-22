import 'package:flutter/material.dart';

class CatButton extends StatelessWidget {
  final Function() onPressedAction;
  final Widget iconWidget;
  final String title;
  const CatButton({
    super.key,
    required this.onPressedAction,
    required this.iconWidget,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor, spreadRadius: 5),
          BoxShadow(
            color: Theme.of(context).cardColor,
            spreadRadius: 5,
            blurRadius: 2,
            offset: Offset.infinite,
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).cardColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: TextButton.icon(
        icon: iconWidget,
        label: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        onPressed: onPressedAction,
      ),
    );
  }
}
