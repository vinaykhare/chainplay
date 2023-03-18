import 'package:flutter/material.dart';

class ChainTileHelp extends StatelessWidget {
  const ChainTileHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(
      //   top: 10,
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
          //color: Theme.of(context).primaryColorLight,
          //borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
      child: Column(
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: Theme.of(context).primaryColorLight,
                child: const Icon(Icons.schedule, size: 15),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Stop Scheduled chain."),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Theme.of(context).primaryColorLight,
                child: const Icon(Icons.pause, size: 15),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Stop Running Chain."),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                child: const Icon(Icons.favorite, size: 15),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Favorite Chain"),
              ),
              CircleAvatar(
                radius: 10,
                backgroundColor: Theme.of(context).primaryColorLight,
                child: const Icon(Icons.arrow_forward, size: 15),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: FittedBox(child: Text("History")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
