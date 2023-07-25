import 'package:chain_activities/widgets/home_button_widget.dart';
import 'package:flutter/material.dart';

class NoChainsView extends StatelessWidget {
  const NoChainsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "No Chains to Play or Schedule",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          HomeButtonWidget(
            chainListFunction: "loadSampleChains",
            buttonText: "Add \n'Sample Chain of Timers'",
            logo: Icon(
              Icons.web_stories,
              size: 50,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          HomeButtonWidget(
            chainListFunction: "navigateToAddChainScreen",
            buttonText: "Create\nYour Own Chain of Timers.",
            logo: Icon(
              Icons.create_outlined,
              size: 50,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          HomeButtonWidget(
            chainListFunction: "navigateToHelpScreen",
            buttonText: "Know\nmore about Chains (CAT).",
            logo: Icon(
              Icons.help,
              size: 50,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
