import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';

class ChainExecutionHeader extends StatelessWidget {
  //final ChainActivity chainActivity;
  final String textInLeft, textInRight, textInBetween, title;

  const ChainExecutionHeader({
    super.key,
    required this.textInBetween,
    required this.textInLeft,
    required this.textInRight,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 2,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    textInLeft,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    assetMap["chainImage"]!,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).disabledColor,
                  child: Text(
                    textInBetween,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Image.asset(
                    assetMap["chainImage"]!,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    textInRight,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
