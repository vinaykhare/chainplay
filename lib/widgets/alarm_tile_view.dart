import 'package:chain_activities/widgets/tile_time_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';

import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/screens/chain_execution_screen.dart';
import 'package:chain_activities/helpers/constants.dart';

class AlarmTileView extends StatelessWidget {
  final Chain chain;
  final bool showHistory, allowFlag;
  final int index;

  const AlarmTileView({
    required super.key,
    required this.chain,
    required this.showHistory,
    required this.allowFlag,
    required this.index,
  });

  Future<void> playTheChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    if (chain.chainStatus == statusExecuting) {
      await chainList.stopChainExecution(chain);
      // if (chain.activities.length == 1) {
      //   await chainList.removeChain(chain);
      // }
    }
    chain.edit = true;
    await chainList.updateChain(chain, false);
    await nav.pushNamed(
      AddChainScreen.routename,
      arguments: chain,
    );
  }

  Future<void> navigateToAddChainOrPlayChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);
    Chain? chainExecution =
        Provider.of<ChainList>(context, listen: false).getRunningChain(chain);

    if (chainExecution == null) {
      //await Provider.of<ChainList>(context, listen: false).loadActivities(chain);
      chain.edit = true;
      await Provider.of<ChainList>(context, listen: false)
          .updateChain(chain, false);
      await nav.pushNamed(
        AddChainScreen.routename,
        arguments: chain,
      );
    } else {
      await Provider.of<ChainList>(context, listen: false)
          .executeChainFurtherPossible(chainExecution);
      await nav.pushNamed(
        PlayChain.routename,
        arguments: {
          payLoadChainExecId: chainExecution.chainExecutionId,
          payLoadChainName: chainExecution.title,
          payLoadChainActivityIndex: index, //0
          payLoadChainActivityCount: chain.chainHistory.length,
        },
      );
    }
  }

  Widget getIconForChain(Chain chain) {
    if (chain.notificationId == trueInDB) {
      return const Icon(Icons.schedule);
    }
    if (chain.chainStatus == statusExecuting) {
      return const Icon(Icons.pause);
    }
    return const Icon(Icons.play_arrow);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => navigateToAddChainOrPlayChain(context),
      child: Column(
        children: [
          ListTile(
            // tileColor: chain.chainStatus == statusDone
            //     ? Theme.of(context).disabledColor
            //     : Theme.of(context).cardColor,
            title: TileTimeView(
              at: chain.at!,
              tileTimeHeading: chain.at!.isAfter(DateTime.now())
                  ? 'Scheduled for: '
                  : 'Started on: ',
              textStyleForDate: Theme.of(context).textTheme.bodyLarge,
              textStyleForTime: Theme.of(context).textTheme.titleLarge,
            ),

            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: IconButton(
                onPressed: () => playTheChain(context),
                icon: getIconForChain(chain),
              ),
            ),
            // leading: Switch(
            //   value: chain.at != null,
            //   onChanged: (value) async {
            //     playTheChain(context);
            //   },
            // ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (allowFlag)
                  IconButton(
                    icon: chain.pinned
                        ? const Icon(Icons.favorite)
                        : const Icon(Icons.favorite_border_outlined),
                    onPressed: () async {
                      chain.pinned = !chain.pinned;
                      await Provider.of<ChainList>(context, listen: false)
                          .updateChain(chain, false);
                    },
                  ),
                if (showHistory)
                  IconButton(
                    onPressed: () async {
                      NavigatorState navState = Navigator.of(context);

                      navState.pushNamed(
                        ChainExecutionScreen.routename,
                        arguments: chain,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
              ],
            ),
          ),
          if (chain.activities.length > 1)
            Text(chain.title)
          else
            const Text("Alarm"),
        ],
      ),
    );
  }
}
