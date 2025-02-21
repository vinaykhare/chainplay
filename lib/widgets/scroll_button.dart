import 'package:flutter/material.dart';

class ScrollButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollButton({super.key, required this.scrollController});
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
      onPressed: () {
        if (scrollController.hasClients) {
          final position = scrollController.position.pixels == 0
              ? scrollController.position.maxScrollExtent
              : scrollController.position.minScrollExtent;
          scrollController.animateTo(
            position,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
          );
        }
      },
      child: const Row(children: [
        Icon(Icons.arrow_upward),
        Text(
          "Scroll",
          textAlign: TextAlign.center,
        ),
        Icon(Icons.arrow_downward),
      ]),
    );
  }
}
