import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/widgets/tile_time_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';

import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/helpers/constants.dart';

class ChainTileView extends StatelessWidget {
  final Chain chain;
  final bool showHistory, allowFlag;
  final int index;

  const ChainTileView({
    required super.key,
    required this.chain,
    required this.showHistory,
    required this.allowFlag,
    required this.index,
  });

  Future<void> playTheChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);
    if (chain.chainStatus == statusExecuting) {
      await Provider.of<ChainList>(context, listen: false)
          .stopChainExecution(chain);
    } else if (chain.activities.length <= 1) {
      await navigateToViewChainOrPlayChain(context);
    } else {
      //await Provider.of<ChainList>(context, listen: false).loadActivities(chain);
      Chain chainExecution =
          await Provider.of<ChainList>(context, listen: false)
              .startChainExecution(chain);
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

  Future<void> navigateToViewChainOrPlayChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);
    Chain? chainExecution =
        Provider.of<ChainList>(context, listen: false).getRunningChain(chain);

    if (chainExecution == null) {
      //await Provider.of<ChainList>(context, listen: false).loadActivities(chain);
      chain.edit = true;
      await Provider.of<ChainList>(context, listen: false)
          .updateChain(chain, false);
      await nav.pushNamed(
        ViewChain.routename,
        arguments: {
          "chain": chain,
        },
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

  Future<void> viewChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);
    await nav.pushNamed(
      ViewChain.routename,
      arguments: {
        "chain": chain,
      },
    );
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
    return Semantics(
      label: "Chain Name: ${chain.title}",
      child: InkWell(
        onTap: () => navigateToViewChainOrPlayChain(context),
        child: Column(
          children: [
            ListTile(
              // tileColor: chain.chainStatus == statusDone
              //     ? Theme.of(context).disabledColor
              //     : Theme.of(context).cardColor,
              // subtitle: Text(chain.title),
              title: TileTimeView(
                at: chain.lastUpdatedAt,
                tileTimeHeading: 'Last Updated on',
                textStyleForDate: Theme.of(context).textTheme.bodyLarge,
                textStyleForTime: Theme.of(context).textTheme.bodyLarge,
              ),

              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColorLight,
                child: IconButton(
                  onPressed: () => playTheChain(context),
                  icon: getIconForChain(chain),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHistory)
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () async {
                        await Provider.of<ChainList>(context, listen: false)
                            .checkAndShareChain(context, chain);
                      },
                    ),
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
                  // if (showHistory)
                  //   IconButton(
                  //     onPressed: () async {
                  //       NavigatorState navState = Navigator.of(context);

                  //       navState.pushNamed(
                  //         ChainExecutionScreen.routename,
                  //         arguments: chain,
                  //       );
                  //     },
                  //     icon: const Icon(Icons.arrow_forward),
                  //   ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    assetMap["chainImage"]!,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
                Text(
                  chain.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                ),
                Expanded(
                  child: Image.asset(
                    assetMap["chainImage"]!,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
