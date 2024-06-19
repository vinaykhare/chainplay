import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:flutter/material.dart';

class ChainSideButton extends StatelessWidget {
  const ChainSideButton({
    super.key,
    required this.chainList,
    required this.chain,
    required this.chainActivityPaused,
    required this.buttonLabel,
    required this.buttonAction,
    required this.buttonIcon,
  });

  final ChainList chainList;
  final Chain chain;
  final ChainActivity? chainActivityPaused;
  final String buttonLabel;
  final Function() buttonAction;
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      //width: appWidth / 2,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 5,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          bottomLeft: Radius.circular(50),
        ),
      ),
      child: TextButton.icon(
        onPressed: buttonAction,
        style: ButtonStyle(
          iconColor: MaterialStateProperty.resolveWith(
            (states) => Theme.of(context).colorScheme.error,
          ),
        ),
        icon: Icon(
          buttonIcon,
        ),
        label: Text(
          buttonLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
