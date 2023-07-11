import 'package:flutter/material.dart';

class ChainTileHelp extends StatelessWidget {
  const ChainTileHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(
      //   top: 10,
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
          //color: Theme.of(context).primaryColorLight,
          //borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: const Icon(Icons.play_arrow, size: 15),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Play Chain"),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: const Icon(Icons.schedule, size: 15),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Stop Alarm"),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: const Icon(Icons.pause, size: 15),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Stop Chain"),
                ),
              ],
            ),

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: const Icon(Icons.touch_app_outlined, size: 20),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("View Chain/Set Alarm"),
                ),
                // CircleAvatar(
                //   radius: 10,
                //   backgroundColor: Theme.of(context).primaryColorLight,
                //   child: const Icon(Icons.swipe_left, size: 15),
                // ),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 8.0),
                //   child: Text("Edit Chain."),
                // ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: const Icon(Icons.swipe_right, size: 20),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Delete Chain"),
                ),
              ],
            ),
            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: const Icon(Icons.favorite, size: 15),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Favorite"),
                ),
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: const Icon(Icons.arrow_forward, size: 15),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: FittedBox(child: Text("Chain Execution History")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
