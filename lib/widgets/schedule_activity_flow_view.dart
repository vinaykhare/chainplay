import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/time_summary.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            child: editActivity != null
                ? ListTile(
                    tileColor: scheduleActivity.edit
                        ? Theme.of(context).focusColor
                        : scheduleActivity.activityDone
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).cardColor,
                    onTap: () async {
                      if (!scheduleActivity.edit) {
                        editActivity!(scheduleActivity);
                      } else {
                        undoEdit!(scheduleActivity);
                      }
                    },
                    title: Text(scheduleActivity.activity.title),
                    subtitle: Text(
                      "${scheduleActivity.activityDone ? 'Completed' : 'will Complete'} ${activities[index].isInterrupted ? ' before scheduled duration' : TransformFunctions.durationToString(scheduleActivity.activityDuration)}.",
                    ),
                    trailing:
                        (scheduleActivity.activityDone || editActivity == null)
                            ? null
                            : ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle),
                              ),
                    leading: Checkbox(
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
                    ),
                  )
                : ListTile(
                    tileColor: scheduleActivity.activityDone
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).cardColor,
                    title: scheduleActivity.at != null
                        ? TimeSummary(
                            cardTitle: scheduleActivity.activity.title,
                            startTime: scheduleActivity.at,
                            endTime: scheduleActivity.endedAt,
                            textInBetween:
                                scheduleActivity.activityDurationLeft != null
                                    ? "Paused"
                                    : null,
                          )
                        : Text(scheduleActivity.activity.title),
                    subtitle: Text(
                      "${scheduleActivity.activityDone ? 'Completed' : 'will Complete'} ${activities[index].isInterrupted ? ' before scheduled duration' : TransformFunctions.durationToString(scheduleActivity.activityDuration)}.",
                    ),
                    leading: Checkbox(
                      key: ValueKey(
                          'activities_checkbox_${scheduleActivity.activity.title}'),
                      value: scheduleActivity.activityDone,
                      onChanged: (value) async {
                        await scheduleList.flipDoneActivity(
                            tempSchedule, scheduleActivity);
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
