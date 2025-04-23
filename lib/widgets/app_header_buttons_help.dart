import 'package:flutter/material.dart';

class AppHeaderButtonsHelp extends StatelessWidget {
  const AppHeaderButtonsHelp({super.key});

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
                Icons.add_box_outlined,
              ),
            ),
            Expanded(
              child: Text(
                "Button redirect to a Create Chain Form",
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
                Icons.upload_outlined,
              ),
            ),
            Expanded(
              child: Text(
                "Buttons opens File Browser to Choose Chain (*.json) file in ChainPlay specific format. ",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
