import 'package:chain_events/widgets/chain_system_wait_activity_flow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/chain_event.dart';
import 'package:chain_events/models/chain_list.dart';
import 'package:chain_events/widgets/system_wait_event.dart';
import 'package:chain_events/widgets/system_wait_event_with_duration.dart';

import 'package:chain_events/widgets/chain_event_flow_view.dart';
//import 'package:chain_events/screens/add_chain_event_screen.dart';

class ChainEventsWidget extends StatelessWidget {
  final Chain tempChain;
  final Function? editEvent, undoEdit, addChainDateToChain;
  const ChainEventsWidget({
    super.key,
    required this.tempChain,
    required this.editEvent,
    required this.undoEdit,
    this.addChainDateToChain,
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

    List<ChainEvent> activities = tempChain.activities;
    activities = activities.reversed.toList();

    Widget getChainEventView(BuildContext context, int index) {
      ChainEvent chainEvent = activities[index];
      switch (chainEvent.event.type) {
        case systemStartEventInDB:
          return Column(
            key: Key(index.toString()),
            children: [
              GestureDetector(
                onLongPressMoveUpdate: (details) {},
                onTap: undoEdit != null && editEvent != null
                    ? () async {
                        if (!chainEvent.edit) {
                          editEvent!(chainEvent);
                        } else {
                          undoEdit!(chainEvent);
                        }
                      }
                    : null,
                child: tempChain.at != null
                    ? SystemWaitEventWithDuration(
                        taskText:
                            "${tempChain.at!.isAfter(DateTime.now()) ? 'Chaind to Start at' : 'Started on '} \n${DateFormat.yMd().add_jms().format(tempChain.at!)}",
                      )
                    : const SystemWaitEvent(taskText: "Start"),
              ),
            ],
          );
        case systemWaitEventInDB:
          return ChainSystemWaitEventFlow(
            key: Key(index.toString()),
            activities: activities,
            arrowWidget: arrowWidget,
            chainEvent: chainEvent,
            chainList: chainList,
            tempChain: tempChain,
            editEvent: editEvent,
            undoEdit: undoEdit,
            lineWidget: lineWidget,
            index: index,
          );
        case waitEventInDB:
        default:
          return ChainEventFlowView(
            key: Key(index.toString()),
            activities: activities,
            arrowWidget: arrowWidget,
            chainEvent: chainEvent,
            chainList: chainList,
            tempChain: tempChain,
            editEvent: editEvent,
            undoEdit: undoEdit,
            lineWidget: lineWidget,
            index: index,
          );
      }
    }

    Widget getChainEventSequence(BuildContext context, int index) {
      return Column(
        key: Key(index.toString()),
        children: [
          getChainEventView(context, index),
        ],
      );
    }

    // return IgnorePointer(
    //   ignoring: undoEdit == null || editEvent == null,
    //   child:
    return ReorderableListView.builder(
      reverse: true,
      buildDefaultDragHandles: true,
      onReorder: (oldIndex, newIndex) {
        oldIndex = activities.length - oldIndex - 1;
        newIndex = activities.length - newIndex - 1;
        chainList.rearrangeActivites(tempChain, oldIndex, newIndex);
      },
      itemCount: activities.length,
      itemBuilder: (context, index) => getChainEventSequence(context, index),
    );
    //);
    // return editEvent == null
    //     ? ListView.builder(
    //         reverse: true,
    //         itemCount: activities.length,
    //         itemBuilder: (context, index) =>
    //             getChainEventSequence(context, index),
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
    //             getChainEventSequence(context, index),
    //       );
  }
}
