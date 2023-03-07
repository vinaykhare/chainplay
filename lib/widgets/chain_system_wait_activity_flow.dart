import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chain_activities/helpers/helper_functions.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/system_wait_activity.dart';
import 'package:chain_activities/widgets/system_wait_activity_with_duration.dart';

class ChainSystemWaitActivityFlow extends StatelessWidget {
  const ChainSystemWaitActivityFlow({
    Key? key,
    required this.activities,
    required this.arrowWidget,
    required this.chainActivity,
    required this.chainList,
    required this.tempChain,
    required this.editActivity,
    required this.undoEdit,
    required this.lineWidget,
    required this.index,
  }) : super(key: key);

  final List<ChainActivity> activities;
  final Widget arrowWidget;
  final ChainActivity chainActivity;
  final ChainList chainList;
  final Chain tempChain;
  final Function? editActivity;
  final Function? undoEdit;
  final Widget lineWidget;
  final int index;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: undoEdit == null || editActivity == null,
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
                  if (!chainActivity.edit) {
                    editActivity!(chainActivity);
                  } else {
                    undoEdit!(chainActivity);
                  }
                },
                child: (activities[index].activityDuration.inSeconds != 0)
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
                          "${activities[index].endedAt != null ? 'Rest Ended ' : 'Rest will end '}${activities[index].isInterrupted ? ' before scheduled duration' : HelperFunctions.durationToString(chainActivity.activityDuration)}.",
                        ),
                      )
                    : Icon(
                        Icons.circle_outlined,
                        size: 15,
                        color: activities[index].edit
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).primaryColor,
                      ),
              ),
            if (index == 0) arrowWidget,
            if (index == 0)
              tempChain.endedAt == null
                  ? const SystemWaitActivity(taskText: 'End')
                  : SystemWaitActivityWithDuration(
                      taskText:
                          'Ended on ${DateFormat.yMd().add_jms().format(tempChain.endedAt!)}',
                    ),
            if (index == 0 && tempChain.repeatType != repeatTypeDoesNotRepeat)
              arrowWidget,
            if (index == 0 && tempChain.repeatType != repeatTypeDoesNotRepeat)
              SystemWaitActivityWithDuration(
                  taskText:
                      "And Repeats every ${tempChain.repeatTypeGap} ${tempChain.repeatType}.\n${(tempChain.repeatCount - 1) > -1 ? 'Chain will repeat ${tempChain.repeatCount - 1} more time/times.' : 'Repeat ends Never.'}")
          ],
        ),
      ),
    );
  }
}
