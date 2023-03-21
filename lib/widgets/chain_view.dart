import 'package:chain_activities/widgets/alarm_tile_view.dart';
import 'package:chain_activities/widgets/chain_tile_view.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/models/chain.dart';

class ChainView extends StatelessWidget {
  final Chain chain;
  final bool showHistory, allowFlag;
  final int index;

  const ChainView({
    required super.key,
    required this.chain,
    required this.showHistory,
    required this.allowFlag,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: chain.activities.length > 1
            ? chain.at != null
                ? Theme.of(context).cardColor.withOpacity(0.7)
                : Theme.of(context).cardColor
            : Theme.of(context).primaryColorDark,
      ),
      child: Column(
        children: [
          //if (chain.activities.length > 1)
          chain.at != null
              // ? Text(
              //     "${chain.at!.isAfter(DateTime.now()) ? 'Scheduled at: ' : 'Started at: '} ${DateFormat.yMEd().add_jms().format(chain.at!)}",
              //   )
              ? AlarmTileView(
                  chain: chain,
                  showHistory: showHistory,
                  allowFlag: allowFlag,
                  key: key,
                  index: index,
                )
              : ChainTileView(
                  chain: chain,
                  showHistory: showHistory,
                  allowFlag: allowFlag,
                  key: key,
                  index: index,
                ),
        ],
      ),
    );
  }
}
