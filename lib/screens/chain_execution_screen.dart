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

    return Scaffold(
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
                itemCount: chain.chainHistory.length,
                itemBuilder: (context, index) {
                  Chain chainExecution = chain.chainHistory[index];
                  int numberOfUserActivites = chainExecution.activities
                      .where((schEx) => schEx.activity.type == waitActivityInDB)
                      .length;
                  return Column(
                    children: [
                      if (index == chain.chainHistory.length - 1)
                        const Text("Executed Chain"),
                      InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          PlayChain.routename,
                          arguments: {
                            payLoadChainExecId: chainExecution.chainExecutionId,
                            payLoadChainName: chainExecution.title,
                            payLoadChainActivityIndex: index,
                            payLoadChainActivityCount:
                                chain.chainHistory.length,
                          },
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              gradient: RadialGradient(
                            colors: [
                              Theme.of(context).backgroundColor,
                              Theme.of(context).scaffoldBackgroundColor,
                            ],
                          )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (chainExecution.endedAt != null)
                                ? StartEndTimeChainWidget(
                                    cardTitle: null,
                                    startTime: chainExecution.at,
                                    endTime: chainExecution.endedAt,
                                    textInBetween: "$numberOfUserActivites",
                                  )
                                : Column(
                                    children: [
                                      const Text("Running Chain"),
                                      ChainView(
                                        chain: chain,
                                        showHistory: false,
                                        allowFlag: false,
                                        key: Key(
                                          index.toString(),
                                        ),
                                        index: index,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (chain.chainHistory.isEmpty ||
                chain.chainHistory.indexWhere(
                        (ch) => ch.chainStatus == statusExecuting) ==
                    -1)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Play Now",
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: IconButton(
                        onPressed: () async {
                          NavigatorState nav = Navigator.of(context);
                          Chain chainExecution = await Provider.of<ChainList>(
                                  context,
                                  listen: false)
                              .startChainExecution(chain);
                          //await chainList.loadActivities(chain);

                          await nav.pushNamed(PlayChain.routename, arguments: {
                            payLoadChainExecId: chainExecution.chainExecutionId,
                            payLoadChainName: chainExecution.title,
                            payLoadChainActivityIndex:
                                chainHistory.length - 1, //0
                            payLoadChainActivityCount: chainHistory.length,
                          });
                        },
                        icon: chain.chainStatus == statusExecuting
                            ? const Icon(Icons.directions_walk)
                            : const Icon(Icons.play_arrow),
                      ),
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
    );
  }
}
