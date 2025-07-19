import 'package:chain_activities/helpers/common_ui.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    Chain chainExecution = await chainList.startChainExecution(chain);

    if (chainExecution.notificationId == trueInDB) {
      await chainList.stopChainExecution(chain);
    } else {
      //await Provider.of<ChainList>(context, listen: false).loadActivities(chain);
      int runningChainActivityIndex =
          chainList.getRunningChainActivityIndex(chainExecution);
      // ChainActivity? chainActivityExecution = runningChainActivityIndex != -1
      //     ? chainExecution.activities[runningChainActivityIndex]
      //     : null;

      await nav.pushNamed(
        PlayChain.routename,
        arguments: {
          payLoadChainExecId: chainExecution.chainExecutionId,
          payLoadChainName: chainExecution.title,
          payLoadChainActivityIndex:
              runningChainActivityIndex != -1 ? runningChainActivityIndex : 0,
          payLoadChainActivityCount: chain.chainHistory.length,
          payLoadChainAction: playChainActionPlay,
        },
      );
    }
  }

  Future<void> scheduleTheChain(BuildContext context) async {
    ScaffoldMessengerState scms = ScaffoldMessenger.of(context);
    DateTime? chainStartTime;

    // NavigatorState nav = Navigator.of(context);

    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    chainStartTime = await CommonUI().getDateTimeDialog(
      context,
      chainStartTime,
    );

    if (chainStartTime == null) {
      return;
    }

    if (chainStartTime.isBefore(DateTime.now())) {
      chain.at = null;
      return;
    }

    chain.at = chainStartTime;

    Chain chainExecution = await chainList.startChainExecution(chain);
    int chainIndex =
        chainList.chains.indexWhere((sch) => sch.title == chainExecution.title);
    if (chainExecution.at != null &&
        chainList.chains[chainIndex].notificationId == noValueInDB) {
      chainExecution.at = null;
      chainList.chains[chainIndex].at = null;
      await chainList.updateChain(
        chainList.chains[chainIndex],
      );
      await chainList.updateChainExecution(
        chainExecution,
      );

      scms.showSnackBar(
        SnackBar(
          content: Text(
            "Unable to Schedule the Chain: ${chainExecution.title}.\n",
          ),
          action: SnackBarAction(
            //textColor: Colors.white,
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Future<void> navigateToViewChainOrPlayChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);
    Chain? chainExecution =
        Provider.of<ChainList>(context, listen: false).getRunningChain(chain);

    if (chainExecution == null) {
      await viewChain(context);
    } else {
      ChainList chainList = Provider.of<ChainList>(context, listen: false);
      int runningChainActivityIndex =
          chainList.getRunningChainActivityIndex(chainExecution);
      // ChainActivity? chainActivityExecution = runningChainActivityIndex != -1
      //     ? chainExecution.activities[runningChainActivityIndex]
      //     : null;
      await nav.pushNamed(
        PlayChain.routename,
        arguments: {
          payLoadChainExecId: chainExecution.chainExecutionId,
          payLoadChainName: chainExecution.title,
          payLoadChainActivityIndex:
              runningChainActivityIndex != -1 ? runningChainActivityIndex : 0,
          payLoadChainActivityCount: chain.chainHistory.length,
          payLoadChainAction: playChainActionPause,
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

  Widget getLeadingIconForChain(BuildContext context, Chain chain) {
    Chain? chainExecution =
        Provider.of<ChainList>(context, listen: false).getRunningChain(chain);
    if (chainExecution != null && chainExecution.notificationId == trueInDB) {
      return Semantics(
        label: "Stop the Chain Execution",
        child: const Icon(
          Icons.stop,
        ),
      );
    }
    // if (chain.chainStatus == statusExecuting) {
    //   return const Icon(Icons.pause);
    // }
    return Semantics(
      label: "Play or Resume this chain",
      child: const Icon(
        Icons.play_arrow,
      ),
    );
  }

  Widget getChainTileTitle(BuildContext context, Chain chain) {
    Chain? chainExecution =
        Provider.of<ChainList>(context, listen: true).getRunningChain(chain);
    if (chainExecution == null) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "with",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        // color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                ),
                Text(
                  "${chain.activities.where((activity) => activity.activity.type == waitActivityInDB).length} Activity",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  "${chain.chainHistory.length.toString()} Execs",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const VerticalDivider(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last Updated",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        // color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                ),
                Text(
                  "on ${DateFormat.yMMMd().format(chain.lastUpdatedAt)}",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  "at ${DateFormat.Hms().format(chain.lastUpdatedAt)}",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      String currentActivityTitle = "";
      int currentActivityIndex = chainExecution.activities.indexWhere(
        (activity) => activity.activityDone == false,
      );
      int currentWaitActivityIndex = chainExecution.activities.indexWhere(
        (activity) =>
            activity.activityDone == false &&
            activity.activity.type == waitActivityInDB,
      );

      if (currentActivityIndex != 0 && currentWaitActivityIndex != -1) {
        currentActivityTitle =
            chainExecution.activities[currentWaitActivityIndex].activity.title;
        if (currentActivityIndex < currentWaitActivityIndex) {
          currentActivityTitle = "Rest before $currentActivityTitle";
        }
      } else if (currentActivityIndex == 0) {
        currentActivityTitle =
            "${DateFormat.jms().format(chainExecution.at!)}\non ${DateFormat.yMMMd().format(chainExecution.at!)}";
      } else {
        currentActivityTitle = "Last activity to complete the chain";
      }

      String status = chainExecution
                  .activities[currentActivityIndex].endActivityNotificationId ==
              noValueInDB
          ? "Paused"
          : currentActivityIndex == 0
              ? "Scheduled"
              : "Running in background";

      // String status = chainExecution.notificationId == trueInDB
      //     ? "Scheduled:\n${DateFormat.yMMMd().format(chainExecution.at!)} at ${DateFormat.Hms().format(chainExecution.at!)}"
      //     : "Paused";
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              "$status at",
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              currentActivityTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Chain Name: ${chain.title}",
      child: InkWell(
        onTap: () => navigateToViewChainOrPlayChain(context),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: chain.at != null
                ? Theme.of(context).cardColor.withValues(alpha: 0.7)
                : Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              ListTile(
                // tileColor: chain.chainStatus == statusDone
                //     ? Theme.of(context).disabledColor
                //     : Theme.of(context).cardColor,
                // subtitle: Text(chain.title),
                title: getChainTileTitle(
                  context,
                  chain,
                ),

                leading: InkWell(
                  onTap: () => playTheChain(context),
                  onLongPress: () => scheduleTheChain(context),
                  child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: getLeadingIconForChain(context, chain)),
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
                  FittedBox(
                    child: Text(
                      chain.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            //color: Theme.of(context).hintColor,
                          ),
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
      ),
    );
  }
}
