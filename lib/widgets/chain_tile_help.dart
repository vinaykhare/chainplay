import 'package:flutter/material.dart';

class ChainTileHelp extends StatelessWidget {
  const ChainTileHelp({super.key});

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    return Container(
      // margin: const EdgeInsets.only(
      //   top: 10,
      // ),
      padding: EdgeInsets.symmetric(horizontal: appWidth * 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.play_circle,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: Text(
                  "Play Chain",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.touch_app_rounded,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: Text(
                  "View Chain",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.pause_circle,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: Text(
                  "Stop Chain",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.share_rounded,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: Text(
                  "Share Chain",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.favorite_outline_outlined,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: Text(
                  "Favorite",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton.icon(
                onPressed: null,
                icon: Icon(
                  Icons.swipe_right_sharp,
                  color: Theme.of(context).primaryColorLight,
                ),
                label: Text(
                  "Delete Chain",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
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
      ),
    );
  }
}
