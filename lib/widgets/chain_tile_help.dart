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
                icon: Icon(
                  Icons.play_circle,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: const Text(
                  "Play Chain",
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.touch_app_rounded,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: const Text(
                  "View Chain",
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.pause_circle,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: const Text(
                  "Stop Chain",
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
                icon: Icon(
                  Icons.share_rounded,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: const Text(
                  "Share Chain",
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.favorite_outline_outlined,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: const Text(
                  "Favorite",
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.swipe_right_sharp,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: const Text(
                  "Delete Chain",
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
