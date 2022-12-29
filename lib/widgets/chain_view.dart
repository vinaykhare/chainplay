import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';

import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/screens/chain_execution_screen.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:intl/intl.dart';

class ChainView extends StatelessWidget {
  final Chain chain;
  final bool showHistory, allowFlag;
  final int index;

  const ChainView(
      {required super.key,
      required this.chain,
      required this.showHistory,
      required this.allowFlag,
      required this.index});

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context);
    NavigatorState nav = Navigator.of(context);
    return Card(
      key: key,
      elevation: 10,
      child: ListTile(
        onTap: () async {
          NavigatorState nav = Navigator.of(context);
          if (chain.chainStatus == statusNotStarted) {
            //await chainList.loadActivities(chain);
            chain.edit = true;
            await chainList.updateChain(chain);
            await nav.pushNamed(
              AddChainScreen.routename,
              arguments: chain,
            );
          } else {
            Chain chainExecution = await chainList.startChainExecution(chain);
            //await chainList.loadActivities(chain);
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
        },
        tileColor: chain.chainStatus == statusDone
            ? Theme.of(context).disabledColor
            : Theme.of(context).cardColor,
        title: Text(chain.title),
        subtitle: chain.at != null
            ? Text(
                "${chain.at!.isAfter(DateTime.now()) ? 'Scheduled at: ' : 'Started at: '} ${DateFormat.yMEd().add_jms().format(chain.at!)}",
              )
            : Text(
                'Last Updated: ${DateFormat.yMEd().add_jms().format(chain.lastUpdatedAt)}',
              ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColorLight,
          child: IconButton(
            onPressed: () async {
              if (chain.chainStatus == statusExecuting) {
                await chainList.stopChainExecution(chain);
              } else {
                //await chainList.loadActivities(chain);
                Chain chainExecution =
                    await chainList.startChainExecution(chain);
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
            },
            icon: chain.chainStatus == statusExecuting
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
        ),
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
                  await chainList.updateChain(chain);
                },
              ),
            if (showHistory)
              IconButton(
                onPressed: () async {
                  Navigator.of(context).pushNamed(
                    ChainExecutionScreen.routename,
                    arguments: chain,
                  );
                },
                icon: const Icon(Icons.arrow_forward),
              ),
          ],
        ),
      ),
    );
  }
}
