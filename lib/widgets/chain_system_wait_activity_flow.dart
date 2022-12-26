import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chain_events/helpers/transform_functions.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/chain_event.dart';
import 'package:chain_events/models/chain_list.dart';
import 'package:chain_events/widgets/system_wait_event.dart';
import 'package:chain_events/widgets/system_wait_event_with_duration.dart';

class ChainSystemWaitEventFlow extends StatelessWidget {
  const ChainSystemWaitEventFlow({
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
    return IgnorePointer(
      ignoring: undoEdit == null || editEvent == null,
      child: GestureDetector(
        onLongPressMoveUpdate:
            (details) {}, // so it cannot be dragged under reorderable list view.
        child: Column(
          key: Key(index.toString()),
          children: [
            if (index != 0) lineWidget,
            if (index != 0)
              InkWell(
                onTap: () {
                  if (!chainEvent.edit) {
                    editEvent!(chainEvent);
                  } else {
                    undoEdit!(chainEvent);
                  }
                },
                child: (activities[index].eventDuration.inSeconds != 0)
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: activities[index].edit
                              ? Theme.of(context).focusColor
                              : Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          "${activities[index].endedAt != null ? 'Rest Ended ' : 'Rest will end '}${activities[index].isInterrupted ? ' before chaind duration' : TransformFunctions.durationToString(chainEvent.eventDuration)}.",
                        ),
                      )
                    : Icon(
                        Icons.circle_outlined,
                        size: 15,
                        color: activities[index].edit
                            ? Theme.of(context).errorColor
                            : Theme.of(context).primaryColor,
                      ),
              ),
            if (index == 0) arrowWidget,
            if (index == 0)
              tempChain.endedAt == null
                  ? const SystemWaitEvent(taskText: 'End')
                  : SystemWaitEventWithDuration(
                      taskText:
                          'Ended on ${DateFormat.yMd().add_jms().format(tempChain.endedAt!)}',
                    ),
          ],
        ),
      ),
    );
  }
}
