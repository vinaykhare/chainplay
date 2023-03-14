import 'package:chain_activities/widgets/chain_system_wait_activity_flow.dart';
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

class ChainActivitiesWidget extends StatelessWidget {
  final Chain tempChain;
  final Function? editActivity, undoEdit, addStartDateToChain;

  final ScrollController? scrollController;
  const ChainActivitiesWidget({
    super.key,
    required this.tempChain,
    required this.editActivity,
    required this.undoEdit,
    required this.scrollController,
    this.addStartDateToChain,
  });

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context);

    final Widget lineWidget = Container(
      width: 2,
      height: 15,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    );

    Widget arrowWidget = Icon(
      Icons.arrow_downward,
      color: Theme.of(context).primaryColor,
    );

    List<ChainActivity> activities = tempChain.activities;
    activities = activities.reversed.toList();

    Widget getChainActivityView(BuildContext context, int index) {
      ChainActivity chainActivity = activities[index];
      switch (chainActivity.activity.type) {
        case systemStartActivityInDB:
          return Column(
            key: Key(index.toString()),
            children: [
              GestureDetector(
                onLongPressMoveUpdate: (details) {},
                onTap: undoEdit != null && editActivity != null
                    ? () async {
                        if (!chainActivity.edit) {
                          editActivity!(chainActivity);
                        } else {
                          undoEdit!(chainActivity);
                        }
                      }
                    : null,
                child: tempChain.at != null
                    ? SystemWaitActivityWithDuration(
                        taskText:
                            "${tempChain.at!.isAfter(DateTime.now()) ? 'Scheduled to Start at' : 'Started on '} \n${DateFormat.yMd().add_jms().format(tempChain.at!)}",
                      )
                    : const SystemWaitActivityWithDuration(
                        taskText: "Tap to Schedule\n this Chain."),
              ),
            ],
          );
        case systemWaitActivityInDB:
          return ChainSystemWaitActivityFlow(
            key: Key(index.toString()),
            activities: activities,
            arrowWidget: arrowWidget,
            chainActivity: chainActivity,
            chainList: chainList,
            tempChain: tempChain,
            editActivity: editActivity,
            undoEdit: undoEdit,
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
            tempChain: tempChain,
            editActivity: editActivity,
            undoEdit: undoEdit,
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
    return ReorderableListView.builder(
      reverse: true,
      buildDefaultDragHandles: true,
      scrollController: scrollController,
      onReorder: (oldIndex, newIndex) {
        oldIndex = activities.length - oldIndex - 1;
        newIndex = activities.length - newIndex - 1;
        chainList.rearrangeActivites(tempChain, oldIndex, newIndex);
      },
      itemCount: activities.length,
      itemBuilder: (context, index) => IgnorePointer(
        key: Key(index.toString()),
        ignoring: tempChain.endedAt != null,
        child: getChainActivitySequence(context, index),
      ),
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
