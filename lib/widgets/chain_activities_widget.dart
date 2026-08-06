import 'package:chain_activities/widgets/chain_system_wait_activity_flow.dart';
import 'package:chain_activities/widgets/scroll_button.dart';
import 'package:chain_activities/widgets/shaded_button.dart';
import 'package:chain_activities/widgets/system_wait_activity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/system_wait_activity_with_duration.dart';

import 'package:chain_activities/widgets/chain_activity_flow_view.dart';
//import 'package:chain_activities/screens/add_chain_activity_screen.dart';

class ChainActivitiesWidget extends StatefulWidget {
  final Chain tempChain;
  final Function? editActivity, undoEdit, updateDurationForAllWaitActivity;

  const ChainActivitiesWidget({
    super.key,
    required this.tempChain,
    required this.editActivity,
    required this.undoEdit,
    this.updateDurationForAllWaitActivity,
  });

  @override
  State<ChainActivitiesWidget> createState() => _ChainActivitiesWidgetState();
}

class _ChainActivitiesWidgetState extends State<ChainActivitiesWidget> {
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context);

    // final Widget lineWidget = Container(
    //   width: 2,
    //   height: 15,
    //   decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    // );

    final Widget lineWidget = Image.asset(
      assetMap["verticalChainImage"]!,
      height: 50,
      width: 30,
      fit: BoxFit.cover,
    );

    // Widget arrowWidget = Icon(
    //   Icons.arrow_downward,
    //   color: Theme.of(context).primaryColor,
    // );
    Widget arrowWidget = Image.asset(
      assetMap["verticalChainImage"]!,
      height: 50,
      width: 30,
      fit: BoxFit.cover,
    );
    List<ChainActivity> activities = widget.tempChain.activities;
    activities = activities.reversed.toList();

    Widget getChainActivityView(BuildContext context, int index) {
      ChainActivity chainActivity = activities[index];
      switch (chainActivity.activity.type) {
        case systemStartActivityInDB:
          return Column(
            key: Key(index.toString()),
            children: [
              widget.tempChain.at != null
                  ? SystemWaitActivityWithDuration(
                      taskText:
                          "${widget.tempChain.at!.isAfter(DateTime.now()) ? 'Scheduled to Start at' : 'Started on '} \n${DateFormat.yMd().add_jms().format(widget.tempChain.at!)}",
                    )
                  : const SystemWaitActivity(taskText: 'Start'),
              if (widget.tempChain.activities.length == 1 &&
                  widget.tempChain.repeatType != repeatTypeDoesNotRepeat &&
                  (widget.tempChain.repeatCount - 1) != 0)
                arrowWidget,
              if (widget.tempChain.activities.length == 1 &&
                  widget.tempChain.repeatType != repeatTypeDoesNotRepeat &&
                  (widget.tempChain.repeatCount - 1) != 0)
                SystemWaitActivityWithDuration(
                  taskText:
                      "And Repeats every ${widget.tempChain.repeatTypeGap} ${widget.tempChain.repeatType}.\n${(widget.tempChain.repeatCount - 1) > -1 ? 'Chain will repeat ${widget.tempChain.repeatCount - 1} more time${(widget.tempChain.repeatCount - 1) > 1 ? "s" : ""}.' : 'Repeat ends Never.'}",
                )
            ],
          );
        case systemWaitActivityInDB:
          return ChainSystemWaitActivityFlow(
            key: Key(index.toString()),
            activities: activities,
            arrowWidget: arrowWidget,
            chainActivity: chainActivity,
            chainList: chainList,
            tempChain: widget.tempChain,
            editActivity: widget.editActivity,
            undoEdit: widget.undoEdit,
            lineWidget: lineWidget,
            index: index,
          );
        case waitActivityInDB:
        default:
          return ChainActivityFlowView(
            key: Key(index.toString()),
            activities: activities,
            arrowWidget: arrowWidget,
            chainActivity: chainActivity,
            chainList: chainList,
            tempChain: widget.tempChain,
            editActivity: widget.editActivity,
            undoEdit: widget.undoEdit,
            lineWidget: lineWidget,
            index: index,
          );
      }
    }

    Widget getChainActivitySequence(BuildContext context, int index) {
      return Column(
        key: Key(index.toString()),
        children: [
          getChainActivityView(context, index),
        ],
      );
    }

    // return IgnorePointer(
    //   ignoring: undoEdit == null || editActivity == null,
    //   child:
    return Stack(
      children: [
        ReorderableListView.builder(
          reverse: true,
          buildDefaultDragHandles: true,
          scrollController: scrollController,
          onReorderItem: (oldIndex, newIndex) {
            if (widget.editActivity == null) {
              return;
            }
            oldIndex = activities.length - oldIndex - 1;
            newIndex = activities.length - newIndex - 1;
            chainList.rearrangeActivites(widget.tempChain, oldIndex, newIndex);
          },
          itemCount: activities.length,
          itemBuilder: (context, index) => IgnorePointer(
            key: Key(index.toString()),
            ignoring: widget.tempChain.endedAt != null,
            child: getChainActivitySequence(context, index),
          ),
        ),
        if (widget.tempChain.activities.length > 4)
          Positioned(
            right: 0,
            bottom: 0,
            child: ScrollButton(
              scrollController: scrollController,
            ),
          ),
        if (widget.updateDurationForAllWaitActivity != null)
          Positioned(
            left: 0,
            bottom: 0,
            child: ShadedButton(
              onPressAction: () {
                widget.updateDurationForAllWaitActivity!();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Set",
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_sharp),
                    ],
                  ),
                  Text(
                    "for all activities",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    //);
    // return editActivity == null
    //     ? ListView.builder(
    //         reverse: true,
    //         itemCount: activities.length,
    //         itemBuilder: (context, index) =>
    //             getChainActivitySequence(context, index),
    //       )
    //     : ReorderableListView.builder(
    //         reverse: true,
    //         buildDefaultDragHandles: true,
    //         onReorder: (oldIndex, newIndex) {
    //           oldIndex = activities.length - oldIndex - 1;
    //           newIndex = activities.length - newIndex - 1;
    //           chainList.rearrangeActivites(tempChain, oldIndex, newIndex);
    //         },
    //         itemCount: activities.length,
    //         itemBuilder: (context, index) =>
    //             getChainActivitySequence(context, index),
    //       );
  }
}
