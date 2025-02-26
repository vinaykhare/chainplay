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

  Future<void> exitScreen() async {
    NavigatorState nav = Navigator.of(context);
    bool allWell = await onPopOut(false);
    allWell && nav.canPop()
        ? nav.pop()
        : nav.pushReplacementNamed(ChainListScreen.routename);
  }

  Future<void> editChain() async {
    if (chain.chainStatus == statusExecuting || invalidChain) {
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
      if (!savedInDb) {
        chain.title = chainList.getValidTitle(chain.title);
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
        onPopInvokedWithResult: (didPop, result) => onPopOut(didPop),
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
                      if (chain.activities.length >= 3)
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
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: appHeight * 0.2,
                                child: Text(
                                  "No use of a chain without a single activity in it",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: exitScreen,
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      label: Text(
                                        "Discard the Chain",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: editChain,
                                      icon: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).cardColor,
                                      ),
                                      label: Text(
                                        "Add activities",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                                "Go back and try with Valid ChainPlay's JSON File.\n",
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "ChainPlay's valid JSON File has a predefined format.\n",
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "ChainPlay's valid JSON File must have a title and more than one activity.\n",
                                style: Theme.of(context).textTheme.labelLarge,
                                textAlign: TextAlign.center,
                              ),
                            ]),
                      ),
                    const ShowBannerAd(),
                    if (savedInDb == true &&
                        invalidChain == false &&
                        chain.activities.length >= 3)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Semantics(
                            label: "Delete this chain.",
                            child: InkWell(
                              onTap: () async {
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
                              child: const CircleAvatar(
                                child: Icon(Icons.delete_forever_outlined),
                              ),
                            ),
                          ),
                          Semantics(
                            label: "Download this chain.",
                            child: InkWell(
                              onTap: () async {
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
                              child: const CircleAvatar(
                                child: Icon(Icons.download),
                              ),
                            ),
                          ),
                          Semantics(
                            label: "Share this chain.",
                            child: InkWell(
                              onTap: () async {
                                await Provider.of<ChainList>(context,
                                        listen: false)
                                    .checkAndShareChain(context, chain);
                              },
                              child: const CircleAvatar(
                                child: Icon(Icons.share_outlined),
                              ),
                            ),
                          ),
                          Semantics(
                            label: "Mark this chain as Favorite.",
                            child: InkWell(
                              onTap: () async {
                                chain.pinned = !chain.pinned;
                                await Provider.of<ChainList>(context,
                                        listen: false)
                                    .updateChain(chain, false);
                              },
                              child: CircleAvatar(
                                child: chain.pinned
                                    ? const Icon(Icons.favorite)
                                    : const Icon(
                                        Icons.favorite_border_outlined),
                              ),
                            ),
                          ),
                          Semantics(
                            label: "Check chain execution history.",
                            child: InkWell(
                              onTap: () async {
                                NavigatorState nav = Navigator.of(context);
                                bool allWell = await onPopOut(false);
                                if (allWell) {
                                  nav.pushNamed(
                                    ChainExecutionScreen.routename,
                                    arguments: chain,
                                  );
                                }
                              },
                              child: const CircleAvatar(
                                child: Icon(Icons.history),
                              ),
                            ),
                          ),
                          Semantics(
                            label: "Play this chain.",
                            child: InkWell(
                              onTap: () => playTheChain(context),
                              child: CircleAvatar(
                                child: getIconForChain(chain),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (savedInDb == false && invalidChain == false)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).cardColor,
                                    Theme.of(context).primaryColorDark,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton.icon(
                                label: Text(
                                  "Not OK! Discard this Chain",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                onPressed: exitScreen,
                                icon: Icon(
                                  Icons.delete_sharp,
                                  color: Theme.of(context).colorScheme.shadow,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).cardColor,
                                    Theme.of(context).primaryColor,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton.icon(
                                label: Text(
                                  "Looks OK! Save this Chain",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                onPressed: () async {
                                  for (var chainActivity in chain.activities) {
                                    await chainList.addChain(
                                        chain, chainActivity);
                                  }
                                  setState(() {
                                    savedInDb = true;
                                  });
                                },
                                icon: Icon(
                                  Icons.save,
                                  color: Theme.of(context).colorScheme.shadow,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: exitScreen,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            chain.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: editChain,
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
