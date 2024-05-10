import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const SkipButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.cancel,
        size: 35,
      ),
      onPressed: onPressed ?? () {},
    );
  }
}
