import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';

import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/helpers/constants.dart';

class ChainTileView extends StatefulWidget {
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

  @override
  State<ChainTileView> createState() => _ChainTileViewState();
}

class _ChainTileViewState extends State<ChainTileView> {
  Future<void> playTheChain(BuildContext context) async {
    NavigatorState nav = Navigator.of(context);

    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    Chain chainExecution = await chainList.startChainExecution(widget.chain);

    if (chainExecution.notificationId == trueInDB) {
      await chainList.stopChainExecution(widget.chain);
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
          payLoadChainActivityCount: widget.chain.chainHistory.length,
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

    chainStartTime = await showDialog<DateTime>(
        context: context,
        builder: (ctx) {
          final TextEditingController addStartDateController =
              TextEditingController();
          final TextEditingController addStartTimeController =
              TextEditingController();
          TimeOfDay selectedTime = TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 1)));

          DateTime chainStartDate = DateTime.now();
          addStartDateController.text =
              DateFormat.yMEd().format(chainStartDate);
          chainStartTime = DateTime(
            chainStartDate.year,
            chainStartDate.month,
            chainStartDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          addStartTimeController.text =
              DateFormat.jms().format(chainStartTime!);
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Schedule Chain"),
                IconButton(
                  icon: Icon(Icons.cancel,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select the date & time when you want to start this chain.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addStartDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Start Date",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          chainStartDate = await showDatePicker(
                                context: ctx,
                                initialDate: chainStartDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              ) ??
                              chainStartDate;
                          addStartDateController.text =
                              DateFormat.yMEd().format(chainStartDate);
                          chainStartTime = DateTime(
                            chainStartDate.year,
                            chainStartDate.month,
                            chainStartDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: addStartTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Start Time",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          selectedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              ) ??
                              selectedTime;
                          chainStartTime = DateTime(
                            chainStartDate.year,
                            chainStartDate.month,
                            chainStartDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          addStartTimeController.text =
                              DateFormat.jms().format(chainStartTime!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  chainStartDate = DateTime.now().subtract(Duration(days: 1));
                  chainStartTime = DateTime(
                    chainStartDate.year,
                    chainStartDate.month,
                    chainStartDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  Navigator.of(ctx).pop(chainStartTime);
                },
                child: const Text("Clear"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(chainStartTime);
                },
                child: const Text("Schedule"),
              ),
            ],
          );
        });

    if (chainStartTime == null) {
      return;
    }

    if (chainStartTime!.isBefore(DateTime.now())) {
      setState(() {
        widget.chain.at = null;
      });
      return;
    }

    setState(() {
      widget.chain.at = chainStartTime;
    });

    Chain chainExecution = await chainList.startChainExecution(widget.chain);
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
    Chain? chainExecution = Provider.of<ChainList>(context, listen: false)
        .getRunningChain(widget.chain);

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
          payLoadChainActivityCount: widget.chain.chainHistory.length,
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
        "chain": widget.chain,
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
        child: (chain.at == null)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "with",
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
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
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
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
              )
            : Column(children: [
                Text(
                  "Scheduled to Execute",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  "on ${DateFormat.yMMMd().format(chain.at!)}",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(width: 10),
                Text(
                  "at ${DateFormat.Hms().format(chain.at!)}",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ]),
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

      if (currentWaitActivityIndex != -1) {
        currentActivityTitle =
            chainExecution.activities[currentWaitActivityIndex].activity.title;
        if (currentActivityIndex < currentWaitActivityIndex) {
          currentActivityTitle = "Rest before $currentActivityTitle";
        }
      } else {
        currentActivityTitle = "Last activity to complete the chain";
      }

      String status = chainExecution.notificationId == trueInDB
          ? "Scheduled:\n${DateFormat.yMMMd().format(chainExecution.at!)} at ${DateFormat.Hms().format(chainExecution.at!)}"
          : "Paused";
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: "Chain Name: ${widget.chain.title}",
      child: InkWell(
        onTap: () => navigateToViewChainOrPlayChain(context),
        onLongPress: () => scheduleTheChain(context),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.chain.at != null
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
                  widget.chain,
                ),

                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    onPressed: () => playTheChain(context),
                    icon: getLeadingIconForChain(context, widget.chain),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showHistory &&
                        Provider.of<ChainList>(context, listen: false)
                                .getRunningChain(widget.chain) ==
                            null)
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () async {
                          await Provider.of<ChainList>(context, listen: false)
                              .checkAndShareChain(context, widget.chain);
                        },
                      ),
                    if (widget.allowFlag)
                      IconButton(
                        icon: widget.chain.pinned
                            ? const Icon(Icons.favorite)
                            : const Icon(Icons.favorite_border_outlined),
                        onPressed: () async {
                          widget.chain.pinned = !widget.chain.pinned;
                          await Provider.of<ChainList>(context, listen: false)
                              .updateChain(widget.chain, false);
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
                      widget.chain.title,
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
