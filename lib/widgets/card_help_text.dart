import 'package:flutter/material.dart';

class CardHelpText extends StatelessWidget {
  final String? title;

  const CardHelpText({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.labelSmall,
            ),
        ],
      ),
    );
  }
}
