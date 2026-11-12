import 'package:flutter/material.dart';

/// The single place that explains the home screen controls.
///
/// It deliberately describes the controls as icons and words only, so it does
/// not depend on any widget being on screen (see `AppResumeClipboard`-style
/// `GlobalKey` tours were removed for that reason). Keep the entries in the
/// same order as the controls appear on a chain tile.
class HomeControlsHelp extends StatelessWidget {
  const HomeControlsHelp({super.key});

  static const List<(IconData, String, String)> _entries = [
    (
      Icons.play_arrow,
      "Play",
      "Tap the round button on a chain to play it.",
    ),
    (
      Icons.alarm,
      "Schedule",
      "Long press the same button to pick a time for the chain. It then runs "
          "on its own, in the background.",
    ),
    (
      Icons.share_outlined,
      "Share",
      "Sends the chain as a file the other person can upload in ChainPlay.",
    ),
    (
      Icons.favorite_border_outlined,
      "Favorite",
      "Keeps a chain in the \"Favorite Chains\" filter at the top.",
    ),
    (
      Icons.swipe_right,
      "Delete",
      "Swipe a chain to the right. You will be asked to confirm.",
    ),
    (
      Icons.open_in_new,
      "Open",
      "Tap anywhere else on a chain to open it: edit, download, or play from "
          "there.",
    ),
  ];

  /// Shows the help in a bottom sheet that fits both orientations.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: const [
                Text(
                  "Chain Controls",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                HomeControlsHelp(),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final entry in _entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(entry.$1),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.$2,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        entry.$3,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
