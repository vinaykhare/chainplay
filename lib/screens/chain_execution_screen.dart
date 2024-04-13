import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/constants.dart';

import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/widgets/chain_view.dart';
import 'package:chain_activities/widgets/start_end_time_chain_widget.dart';

//import 'package:chain_activities/widgets/app_drawer.dart';

class ChainExecutionScreen extends StatelessWidget {
  static String routename = "/chain_history";

  const ChainExecutionScreen({super.key});

  // late ChainList chainList;
  // List<Chain> chains = [];

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   chainList = Provider.of<ChainList>(context, listen: true);
  //   // chainList.fetchChains().then((value) {
  //   //   setState(() {
  //   //     chains = value;
  //   //   });
  //   // });
  // }

  Text headerText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text contentText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  Card chainDate(String title, DateTime schDate) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            headerText(title),
            const Divider(
              thickness: 1,
            ),
            contentText(
              DateFormat.yMEd().format(
                schDate,
              ),
            ),
            contentText(
              DateFormat.jms().format(
                schDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Chain chain = Chain();
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    List<Chain> chainHistory = [];
    if (ModalRoute.of(context)?.settings.arguments != null) {
      Chain chainArg = ModalRoute.of(context)?.settings.arguments as Chain;
      chain = chainList.chains.firstWhere((sch) => sch.title == chainArg.title);

      //tempChain.loadActivities();
    }

    List<Chain> executedChains = chain.chainHistory
        .where((chain) => chain.chainStatus == statusDone)
        .toList();
    List<Chain> executingChains = chain.chainHistory
        .where((chain) => chain.chainStatus != statusDone)
        .toList();
    return Semantics(
      label: "Chain Execution Screen",
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  // onReorder: (oldIndex, newIndex) =>
                  //     Provider.of<ChainList>(context, listen: false)
                  //         .rearrangeChains(oldIndex, newIndex),
                  itemCount: executedChains.length,
                  itemBuilder: (context, index) {
                    Chain chainExecution = executedChains[index];
                    int numberOfUserActivites = chainExecution.activities
                        .where(
                            (schEx) => schEx.activity.type == waitActivityInDB)
                        .length;
                    return Column(
                      children: [
                        if (index == executedChains.length - 1)
                          Text(
                            "Executed Chains",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        InkWell(
                          onTap: () => Navigator.of(context).pushNamed(
                            PlayChain.routename,
                            arguments: {
                              payLoadChainExecId:
                                  chainExecution.chainExecutionId,
                              payLoadChainName: chainExecution.title,
                              payLoadChainActivityIndex:
                                  chainExecution.activities.length - 1,
                              payLoadChainActivityCount:
                                  chain.chainHistory.length,
                              payLoadChainAction: playChainActionPause,
                            },
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: RadialGradient(
                              colors: [
                                chainExecution.notificationId == trueInDB
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.background,
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            )),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: StartEndTimeChainWidget(
                                cardTitle: null,
                                startTime: chainExecution.at,
                                endTime: chainExecution.endedAt,
                                textInBetween: "$numberOfUserActivites",
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).cardColor,
                    ),
                    child: const ShowBannerAd(),
                  ),
                  if (executingChains.isEmpty)
                    const Text(
                      "Play Now",
                      textAlign: TextAlign.center,
                    ),
                  if (executingChains.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColorLight,
                        child: IconButton(
                          onPressed: () async {
                            if (chain.chainStatus == statusExecuting) {
                              await chainList.stopChainExecution(chain);
                            } else {
                              NavigatorState nav = Navigator.of(context);
                              Chain chainExecution =
                                  await Provider.of<ChainList>(context,
                                          listen: false)
                                      .startChainExecution(chain);
                              //await chainList.loadActivities(chain);

                              await nav
                                  .pushNamed(PlayChain.routename, arguments: {
                                payLoadChainExecId:
                                    chainExecution.chainExecutionId,
                                payLoadChainName: chainExecution.title,
                                payLoadChainActivityIndex: 0,
                                payLoadChainActivityCount: chainHistory.length,
                                payLoadChainAction: playChainActionPlay,
                              });
                            }
                          },
                          icon: chain.chainStatus == statusExecuting
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                        ),
                      ),
                    ),
                  if (executingChains.isNotEmpty)
                    Text(
                      "Running Chain",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  if (executingChains.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30)),
                      ),
                      child: ChainView(
                        chain: chain,
                        showHistory: false,
                        allowFlag: false,
                        key: Key(
                          executingChains.first.index.toString(),
                        ),
                        index: executingChains.first.index,
                      ),
                    ),
                ],
              ),
              AppBar(
                centerTitle: true,
                title: Text(chain.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
