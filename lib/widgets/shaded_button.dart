import 'package:flutter/material.dart';

class ShadedButton extends StatelessWidget {
  final Function onPressAction;
  final Widget child;

  const ShadedButton({
    super.key,
    required this.onPressAction,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    //return ElevatedButton.icon(
    return ElevatedButton(
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) =>
                  Theme.of(context).secondaryHeaderColor.withValues(alpha: 0.1),
            ),
          ),
      onPressed: () => onPressAction(),
      child: child,
    );
  }
}
