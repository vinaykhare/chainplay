import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/chain_execution_screen.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
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
  bool initializing = true, savedInDb = true, invalidChain = false;
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

    chainList = Provider.of<ChainList>(context, listen: false);
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

      await nav.pushReplacementNamed(
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

  Widget getIconForChain(Chain chain) {
    if (chain.notificationId == trueInDB) {
      return const Icon(Icons.schedule);
    }
    if (chain.chainStatus == statusExecuting) {
      return const Icon(Icons.pause_circle_outline_rounded);
    }
    return const Icon(Icons.play_arrow_outlined);
  }

  Future<bool> onPopOut(bool didPop) async {
    if (didPop) {
      return true;
    }
    await chainList.cancelIntentSubscription();
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

      if (chainList.sharedFile != null) {
        savedInDb = false;
        try {
          File sharedFile = File(chainList.sharedFile!.path);
          String fileString = sharedFile.readAsStringSync();
          Map<String, dynamic> jsonData = jsonDecode(fileString);
          if (jsonData['title'] != null && jsonData['activities'] != null) {
            chain = Chain.fromJson(jsonData);
          } else {
            // chain = Chain();
            // invalidChain = true;
            // chainList.cancelIntentSubscription();
            throw "invalid";
          }
        } catch (e) {
          chain = Chain();
          invalidChain = true;
          //chainList.cancelIntentSubscription();
        }
      } else {
        Map<String, dynamic> viewArgs =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        chain = viewArgs['chain'];
        savedInDb = viewArgs['savedInDb'] ?? true;
        invalidChain = viewArgs['invalidChain'] ?? false;
      }
      initializing = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return Semantics(
      label: "View Chain Screen",
      child: PopScope(
        canPop: false,
        onPopInvoked: onPopOut,
        child: Scaffold(
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
                    if (invalidChain == false)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChainActivitiesWidget(
                            tempChain: chain,
                            editActivity: null,
                            undoEdit: null,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(50),
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Invalid Chain\n",
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "Go back and try with Valid CAT's JSON File.\n",
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "CAT's valid JSON File has a predefined format.\n",
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "CAT's valid JSON File must have a title and more than one activity.\n",
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                            ]),
                      ),
                    const ShowBannerAd(),
                    if (savedInDb == true && invalidChain == false)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () async {
                                NavigatorState nav = Navigator.of(context);
                                bool? dialogResponse = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Deletion"),
                                      content: const Text(
                                          "Are you sure about deleting this Chain?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(
                                            "Yes, Delete the Chain!",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(
                                            "No, chose this option by mistake.",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inverseSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (dialogResponse == true) {
                                  await chainList.removeChain(chain);
                                  nav.pop();
                                }
                              },
                              icon: const Icon(Icons.delete_forever_outlined),
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () async {
                                ScaffoldMessengerState scm =
                                    ScaffoldMessenger.of(context);
                                String downloadResponse =
                                    await Provider.of<ChainList>(context,
                                            listen: false)
                                        .checkAndDownloadChain(context, chain);

                                scm.showSnackBar(SnackBar(
                                  content: Text(downloadResponse),
                                  duration: const Duration(seconds: 5),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    onPressed: () {},
                                  ),
                                ));
                              },
                              icon: const Icon(Icons.download),
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () async {
                                await Provider.of<ChainList>(context,
                                        listen: false)
                                    .checkAndShareChain(context, chain);
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
                                await Provider.of<ChainList>(context,
                                        listen: false)
                                    .updateChain(chain, false);
                              },
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () async {
                                NavigatorState nav = Navigator.of(context);
                                bool allWell = await onPopOut(false);
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
                    if (savedInDb == false && invalidChain == false)
                      ElevatedButton(
                        child: const Text("SAVE"),
                        onPressed: () async {
                          for (var chainActivity in chain.activities) {
                            await chainList.addChain(chain, chainActivity);
                          }
                          setState(() {
                            savedInDb = true;
                          });
                        },
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () async {
                            NavigatorState nav = Navigator.of(context);
                            bool allWell = await onPopOut(false);
                            allWell && nav.canPop()
                                ? nav.pop()
                                : nav.pushReplacementNamed(
                                    ChainListScreen.routename);
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Text(
                          chain.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () async {
                            if (chain.chainStatus == statusExecuting ||
                                invalidChain) {
                              return;
                            }
                            NavigatorState nav = Navigator.of(context);
                            bool allWell = await onPopOut(false);
                            if (allWell && savedInDb && !invalidChain) {
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
                            color: invalidChain ||
                                    chain.chainStatus == statusExecuting ||
                                    !savedInDb
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
        ),
      ),
    );
  }
}
