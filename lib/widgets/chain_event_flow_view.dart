import 'dart:io';
import 'package:chain_events/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:chain_events/helpers/transform_functions.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/chain_event.dart';
import 'package:chain_events/models/chain_list.dart';
import 'package:chain_events/widgets/start_end_time_chain_widget.dart';

class ChainEventFlowView extends StatelessWidget {
  const ChainEventFlowView({
    Key? key,
    required this.activities,
    required this.arrowWidget,
    required this.chainEvent,
    required this.chainList,
    required this.tempChain,
    required this.editEvent,
    required this.undoEdit,
    required this.lineWidget,
    required this.index,
  }) : super(key: key);

  final List<ChainEvent> activities;
  final Widget arrowWidget;
  final ChainEvent chainEvent;
  final ChainList chainList;
  final Chain tempChain;
  final Function? editEvent;
  final Function? undoEdit;
  final Widget lineWidget;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        arrowWidget,
        Card(
          elevation: 10,
          color: chainEvent.endedAt != null
              ? Theme.of(context).selectedRowColor
              : Theme.of(context).cardColor,
          child: Dismissible(
            direction: editEvent != null
                ? DismissDirection.startToEnd
                : DismissDirection.none,
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).errorColor,
              ),
            ),
            key: ValueKey('activities_dimissible_${chainEvent.event.eventId}'),
            onDismissed: (_) async {
              await chainList.removeEventFromChain(tempChain, chainEvent);
            },
            child: editEvent != null
                ? ListTile(
                    onTap: () async {
                      if (!chainEvent.edit) {
                        editEvent!(chainEvent);
                      } else {
                        undoEdit!(chainEvent);
                      }
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            chainEvent.event.title,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              height: 100,
                              margin: const EdgeInsets.all(5),
                              child: chainEvent.event.specification != null &&
                                      chainEvent.event.specification![
                                              activitySpecImagePath] !=
                                          null
                                  ? Image.file(
                                      File(
                                        chainEvent.event.specification![
                                            activitySpecImagePath],
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/logo/logo.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "${chainEvent.endedAt != null ? 'Completed' : 'will Complete'} ${activities[index].isInterrupted ? ' before scheduled duration' : TransformFunctions.durationToString(chainEvent.eventDuration)}.",
                    ),
                    trailing: (chainEvent.endedAt != null || editEvent == null)
                        ? null
                        : ReorderableDragStartListener(
                            index: index,
                            child: const Icon(Icons.drag_handle),
                          ),
                    leading: Checkbox(
                      key: ValueKey(
                          'activities_checkbox_${chainEvent.event.title}'),
                      value: chainEvent.endedAt != null,
                      onChanged: (value) async {
                        await chainList.flipDoneEvent(tempChain, chainEvent);
                      },
                    ),
                  )
                : Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                chainEvent.event.title,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  height: 100,
                                  margin: const EdgeInsets.all(5),
                                  child:
                                      chainEvent.event.specification != null &&
                                              chainEvent.event.specification![
                                                      activitySpecImagePath] !=
                                                  null
                                          ? Image.file(
                                              File(
                                                chainEvent.event.specification![
                                                    activitySpecImagePath],
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/logo/logo.png',
                                              fit: BoxFit.cover,
                                            ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          "${chainEvent.endedAt != null ? 'Completed' : 'will Complete'} ${activities[index].isInterrupted ? ' before scheduled duration' : TransformFunctions.durationToString(chainEvent.eventDuration)}.",
                        ),
                        leading: Checkbox(
                          key: ValueKey(
                              'activities_checkbox_${chainEvent.event.title}'),
                          value: chainEvent.endedAt != null,
                          onChanged: (value) async {
                            await chainList.flipDoneEvent(
                                tempChain, chainEvent);
                          },
                        ),
                      ),
                      if (chainEvent.at != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StartEndTimeChainWidget(
                            cardTitle: null,
                            startTime: chainEvent.at,
                            endTime: chainEvent.endedAt,
                            textInBetween: chainEvent.eventDurationLeft != null
                                ? "Paused"
                                : null,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
