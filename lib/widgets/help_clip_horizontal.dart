import 'package:flutter/material.dart';

class HelpClipHorizontal extends StatelessWidget {
  const HelpClipHorizontal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 65,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Use below Text Bar to add Timer Activities to this Chain.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Theme.of(context).primaryColorLight,
              ),
              child: Row(
                children: const [
                  Text("Click"),
                  Icon(Icons.watch),
                  Text(" to view and edit Timer Properties.")
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
                color: Theme.of(context).primaryColorLight,
              ),
              child: Row(
                children: const [
                  Text("Click"),
                  Icon(Icons.add_task_outlined),
                  Text(" to submit and add timer to this Chain.")
                ],
              ),
            ),
          ],
        ),
        const Icon(Icons.arrow_downward),
      ],
    );
  }
}
