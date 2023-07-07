import 'package:chain_activities/widgets/card_help_text.dart';
import 'package:chain_activities/widgets/cat_container_header.dart';

import 'package:flutter/material.dart';

class CatContainer extends StatelessWidget {
  final String containerTitle;
  final String? helpText;
  final Widget childWidget;
  final VoidCallback? onPressed;
  const CatContainer({
    super.key,
    required this.childWidget,
    required this.containerTitle,
    this.helpText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    //double appWidth = MediaQuery.of(context).size.width - 16;
    return SingleChildScrollView(
      child: Column(
        children: [
          CatContainerHeader(
            containerTitle: containerTitle,
            onPressed: onPressed,
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            child: childWidget,
          ),
          if (helpText != null)
            CardHelpText(
              title: helpText!,
            ),
        ],
      ),
    );
  }
}
