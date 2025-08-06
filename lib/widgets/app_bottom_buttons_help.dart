import 'package:flutter/material.dart';

class AppBottomButtonsHelp extends StatelessWidget {
  const AppBottomButtonsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: appWidth * 0.1,
              child: const Icon(
                Icons.menu,
              ),
            ),
            Expanded(
              child: Text(
                "Opens the App Drawer with options to create the chain and change settings.",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            SizedBox(
              width: appWidth * 0.1,
              child: const Icon(
                Icons.search,
              ),
            ),
            Expanded(
              child: Text(
                "Search bar to search for a specific chain.",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
