import 'package:flutter/material.dart';

class ChainTileHelp extends StatelessWidget {
  const ChainTileHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //const Divider(),
        FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.play_circle,
                ),
                label: Text(
                  "Play Chain",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.touch_app_rounded,
                ),
                label: Text(
                  "View Chain",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.stop,
                ),
                label: Text(
                  "Stop Chain",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     CircleAvatar(
        //       radius: 10,
        //       backgroundColor: Theme.of(context).primaryColorLight,
        //       child: const Icon(Icons.play_arrow, size: 15),
        //     ),
        //     const Text("Play Chain"),
        //     CircleAvatar(
        //       radius: 10,
        //       backgroundColor: Theme.of(context).primaryColorLight,
        //       child: const Icon(Icons.pause, size: 15),
        //     ),
        //     const Text("Stop Chain"),
        //   ],
        // ),

        // const Divider(),
        FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.share_rounded,
                ),
                label: Text(
                  "Share Chain",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.favorite_outline_outlined,
                ),
                label: Text(
                  "Favorite",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: const Icon(
                  Icons.swipe_right_sharp,
                ),
                label: Text(
                  "Delete Chain",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     CircleAvatar(
        //       radius: 10,
        //       backgroundColor: Theme.of(context).primaryColorLight,
        //       child: const Icon(Icons.touch_app_outlined, size: 20),
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 8.0),
        //       child: Text("View Chain"),
        //     ),
        //     CircleAvatar(
        //       radius: 10,
        //       backgroundColor: Theme.of(context).primaryColorLight,
        //       child: const Icon(Icons.favorite, size: 15),
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 8.0),
        //       child: Text("Favorite"),
        //     ),
        //     const SizedBox(
        //       width: 50,
        //     ),
        //     CircleAvatar(
        //       radius: 10,
        //       backgroundColor: Theme.of(context).primaryColorLight,
        //       child: const Icon(Icons.swipe_right, size: 20),
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 8.0),
        //       child: Text("Delete Chain"),
        //     ),
        //   ],
        // ),
        // const Divider(),
      ],
    );
  }
}
