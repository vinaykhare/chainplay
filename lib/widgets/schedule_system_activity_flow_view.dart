import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/rest_task.dart';
import 'package:schedule_it/widgets/rest_task_with_duration.dart';

class ScheduleSystemActivityFlowView extends StatelessWidget {
  const ScheduleSystemActivityFlowView({
    Key? key,
    required this.activities,
    required this.arrowWidget,
    required this.scheduleActivity,
    required this.scheduleList,
    required this.tempSchedule,
    required this.editActivity,
    required this.undoEdit,
    required this.lineWidget,
    required this.index,
    required this.showCheckBox,
  }) : super(key: key);

  final List<ScheduleActivity> activities;
  final Widget arrowWidget;
  final ScheduleActivity scheduleActivity;
  final ScheduleList scheduleList;
  final Schedule tempSchedule;
  final Function? editActivity;
  final Function? undoEdit;
  final Widget lineWidget;
  final int index;
  final bool showCheckBox;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressMoveUpdate:
          (details) {}, // so it cannot be dragged under reorderable list view.
      child: Column(
        key: Key(index.toString()),
        children: [
          if (index != 0) lineWidget,
          if (index != 0)
            InkWell(
              onTap: editActivity != null && undoEdit != null
                  ? () {
                      if (!scheduleActivity.edit) {
                        editActivity!(scheduleActivity, false);
                      } else {
                        undoEdit!(scheduleActivity, false);
                      }
                    }
                  : () async {
                      await scheduleList.flipDoneRestAfterActivity(
                          tempSchedule, scheduleActivity);
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
                        "${activities[index].endedAt != null ? 'Rest Ended ' : 'Rest will end '}${activities[index].restDone ? ' before scheduled duration' : TransformFunctions.durationToString(scheduleActivity.activityDuration)}.",
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
          if (index == 0) const RestTask(taskText: "End"),
        ],
      ),
    );
  }
}
