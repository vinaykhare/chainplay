import 'package:flutter/material.dart';

class ScrollButton extends StatelessWidget {
  final ScrollController scrollController;

  const ScrollButton({super.key, required this.scrollController});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        backgroundColor:
            Theme.of(context).secondaryHeaderColor.withOpacity(0.1),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      icon: scrollController.hasClients && scrollController.position.pixels == 0
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
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
      label:
          scrollController.hasClients && scrollController.position.pixels == 0
              ? const Text(
                  "Start\nof Chain",
                  textAlign: TextAlign.center,
                )
              : const Text(
                  "End\nof Chain",
                  textAlign: TextAlign.center,
                ),
    );
  }
}
