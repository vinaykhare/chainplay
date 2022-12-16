import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/rest_task.dart';

class ScheduleActivityFlowView extends StatelessWidget {
  const ScheduleActivityFlowView({
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
    return Column(
      children: [
        if (index == activities.length - 1) const RestTask(taskText: "Start"),
        arrowWidget,
        Card(
          elevation: 10,
          child: Dismissible(
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).focusColor,
              ),
            ),
            key: ValueKey(
                'activities_dimissible_${scheduleActivity.activity.activityId}'),
            onDismissed: (_) async {
              await scheduleList.removeActivityFromSchedule(
                  tempSchedule, scheduleActivity);
            },
            child: ListTile(
              tileColor: scheduleActivity.edit
                  ? Theme.of(context).focusColor
                  : scheduleActivity.activityDone
                      ? Theme.of(context).disabledColor
                      : Theme.of(context).cardColor,
              onTap: editActivity != null && undoEdit != null
                  ? () async {
                      if (!scheduleActivity.edit) {
                        editActivity!(scheduleActivity, false);
                      } else {
                        undoEdit!(scheduleActivity, false);
                      }
                    }
                  : null,
              title: Text(scheduleActivity.activity.title),
              subtitle: Text(
                "${scheduleActivity.activityDone ? 'Completed' : 'will Complete'} ${activities[index].restDone ? ' before scheduled duration' : TransformFunctions.durationToString(scheduleActivity.activityDuration)}.",
              ),
              trailing: scheduleActivity.activityDone
                  ? null
                  : scheduleActivity.notificationId != noValueInDB
                      ? TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.notifications_active),
                          label: Text(
                            scheduleActivity.notificationId.toString(),
                          ),
                        )
                      : editActivity != null
                          ? ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            )
                          : null,
              leading: showCheckBox
                  ? Checkbox(
                      key: ValueKey(
                          'activities_checkbox_${scheduleActivity.activity.title}'),
                      value: scheduleActivity.activityDone,
                      onChanged: (value) async {
                        // setState(() {
                        //   activity.activityDone = value ?? false;
                        // });
                        await scheduleList.flipDoneActivity(
                            tempSchedule, scheduleActivity);
                      },
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
