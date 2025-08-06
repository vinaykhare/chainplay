import 'package:chain_activities/widgets/home_button_widget.dart';
import 'package:flutter/material.dart';

class NoChainsView extends StatelessWidget {
  const NoChainsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "No Chains to Play",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        HomeButtonWidget(
          chainListFunction: "navigateToAddChainScreen",
          buttonText: "Create",
          buttonSubText: "Your Own Chain of Timers.",
          logo: Icon(
            Icons.add_box_outlined,
            size: 50,
          ),
        ),
        HomeButtonWidget(
          chainListFunction: "uploadChain",
          buttonText: "Upload",
          buttonSubText: "Chain using App's *.json file.",
          logo: Icon(
            Icons.upload_outlined,
            size: 50,
          ),
        ),
        HomeButtonWidget(
          chainListFunction: "loadSampleChains",
          buttonText: "Add",
          buttonSubText: "Sample Chains & Play them.",
          logo: Icon(
            Icons.add_circle_outline_sharp,
            size: 50,
          ),
        ),
        // HomeButtonWidget(
        //   chainListFunction: "navigateToHelpScreen",
        //   buttonText: "Know",
        //   buttonSubText: "more about ChainPlay.",
        //   logo: Icon(
        //     Icons.help_outline,
        //     size: 50,
        //   ),
        // ),
      ],
    );
  }
}
