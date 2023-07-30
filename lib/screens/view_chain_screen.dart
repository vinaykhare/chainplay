import 'dart:async';

import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/chain_execution_screen.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/widgets/chain_activities_widget.dart';

class ViewChain extends StatefulWidget {
  static String routename = "view_chain";
  const ViewChain({super.key});
  @override
  State<ViewChain> createState() => _ViewChainState();
}

class _ViewChainState extends State<ViewChain> {
  late Chain chain;
  late Chain parentChainItem;
  late ChainList chainList;
  int invokeCounter = 0;
  bool initializing = true;
  //bool buildDone = false;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     buildDone = true;
  //   });
  // }

  Future<void> playTheChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);
    if (chain.chainStatus == statusExecuting) {
      await Provider.of<ChainList>(context, listen: false)
          .stopChainExecution(chain);
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
          payLoadChainActivityIndex: 0,
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
      return const Icon(Icons.pause_circle_outline_rounded);
    }
    return const Icon(Icons.play_arrow_outlined);
  }

  Future<bool> onPopOut() async {
    return true;
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      chainList = Provider.of<ChainList>(context, listen: false);

      // if (chainList.notificationCameForChain != null) {
      //   chain = chainList.notificationCameForChain!;
      //   chainList.notificationCameForChain = null;
      // } else {
      Map<String, dynamic> chArg =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      chain = chainList.chains
          .firstWhere((ch) => ch.title == chArg[payLoadChainName]);

      initializing = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            // margin: const EdgeInsets.only(top: 50),
            // padding: const EdgeInsets.all(10),
            height: appHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChainActivitiesWidget(
                      tempChain: chain,
                      editActivity: null,
                      undoEdit: null,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      child: IconButton(
                        onPressed: () async {
                          NavigatorState nav = Navigator.of(context);
                          await chainList.removeChain(chain);
                          nav.pop();
                        },
                        icon: const Icon(Icons.delete_forever_outlined),
                      ),
                    ),
                    CircleAvatar(
                      child: IconButton(
                        onPressed: () async {
                          await Provider.of<ChainList>(context, listen: false)
                              .downloadChain(chain);
                        },
                        icon: const Icon(Icons.share_outlined),
                      ),
                    ),
                    CircleAvatar(
                      child: IconButton(
                        icon: chain.pinned
                            ? const Icon(Icons.favorite)
                            : const Icon(Icons.favorite_border_outlined),
                        onPressed: () async {
                          chain.pinned = !chain.pinned;
                          await Provider.of<ChainList>(context, listen: false)
                              .updateChain(chain, false);
                        },
                      ),
                    ),
                    CircleAvatar(
                      child: IconButton(
                        onPressed: () async {
                          NavigatorState nav = Navigator.of(context);
                          bool allWell = await onPopOut();
                          if (allWell) {
                            nav.pushNamed(
                              ChainExecutionScreen.routename,
                              arguments: chain,
                            );
                          }
                        },
                        icon: const Icon(Icons.history),
                      ),
                    ),
                    CircleAvatar(
                      child: IconButton(
                        onPressed: () => playTheChain(context),
                        icon: getIconForChain(chain),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () async {
                        NavigatorState nav = Navigator.of(context);
                        bool allWell = await onPopOut();
                        allWell && nav.canPop()
                            ? nav.pop()
                            : nav.pushNamed(ChainListScreen.routename);
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Text(
                      chain.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () async {
                        if (chain.chainStatus == statusExecuting) {
                          return;
                        }
                        NavigatorState nav = Navigator.of(context);
                        bool allWell = await onPopOut();
                        if (allWell) {
                          chain.edit = true;
                          await chainList.updateChain(chain, false);
                          await nav.pushNamed(
                            AddChainScreen.routename,
                            arguments: chain,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        color: chain.chainStatus == statusExecuting
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
