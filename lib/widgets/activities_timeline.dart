import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/rest_task.dart';
import 'package:schedule_it/widgets/rest_task_with_duration.dart';
//import 'package:schedule_it/screens/add_schedule_activity_screen.dart';

class ActivitiesTimeline extends StatelessWidget {
  final Schedule tempSchedule;
  final Function editActivity, undoEdit;
  final String error;
  const ActivitiesTimeline({
    super.key,
    required this.tempSchedule,
    required this.editActivity,
    required this.undoEdit,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);

    final Widget lineWidget = Container(
      width: 2,
      height: 15,
      decoration: const BoxDecoration(color: Colors.amber),
    );

    const Widget arrowWidget = Icon(
      Icons.arrow_downward,
      color: Colors.amber,
    );

    if (error != "") {
      tempSchedule.activities = [];
    }

    return FutureBuilder(
      future: scheduleList.loadActivities(tempSchedule),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List<ScheduleActivity> activities =
            snapshot.data as List<ScheduleActivity>;
        activities = activities.reversed.toList();
        return ReorderableListView.builder(
          reverse: true,
          buildDefaultDragHandles: true,
          onReorder: (oldIndex, newIndex) {
            oldIndex = activities.length - oldIndex - 1;
            newIndex = activities.length - newIndex - 1;
            scheduleList.rearrangeActivites(tempSchedule, oldIndex, newIndex);
          },
          itemCount: activities.length,
          itemBuilder: (context, index) {
            ScheduleActivity scheduleActivity = activities[index];
            return Column(
              key: Key(index.toString()),
              children: [
                if (index == activities.length - 1)
                  const RestTask(taskText: "Start"),
                arrowWidget,
                Card(
                  elevation: 10,
                  child: Dismissible(
                    background: Container(
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
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
                          ? Colors.yellow
                          : scheduleActivity.activityDone
                              ? Colors.grey
                              : Theme.of(context).cardColor,
                      onTap: () async {
                        if (!scheduleActivity.edit) {
                          editActivity(scheduleActivity, false);
                        } else {
                          undoEdit(scheduleActivity, false);
                        }
                      },
                      title: Text(scheduleActivity.activity.title),
                      subtitle: Text(
                        "${scheduleActivity.activityDone ? 'Completed' : 'will Complete'} ${TransformFunctions.durationToString(scheduleActivity.activityDuration)}.",
                      ),
                      trailing: scheduleActivity.activityDone
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
                          scheduleList.flipDoneActivity(
                              tempSchedule, scheduleActivity);
                        },
                      ),
                    ),
                  ),
                ),
                if (index != 0) lineWidget,
                if (index != 0)
                  InkWell(
                    onTap: () {
                      if (!scheduleActivity.editNextActivity) {
                        editActivity(scheduleActivity, true);
                      } else {
                        undoEdit(scheduleActivity, true);
                      }
                    },
                    child: (activities[index].nextActivityAfter.inSeconds != 0)
                        ? Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20),
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              "${activities[index].activityDone ? 'Rest Ended ' : 'Rest will end '}${TransformFunctions.durationToString(scheduleActivity.nextActivityAfter)}.",
                            ),
                          )
                        : Icon(
                            Icons.circle_outlined,
                            size: 15,
                            color: activities[index].editNextActivity
                                ? Colors.red
                                : Colors.amber,
                          ),
                  ),
                if (index == 0) arrowWidget,
                if (index == 0)
                  InkWell(
                      onTap: () {
                        if (!scheduleActivity.editNextActivity) {
                          editActivity(scheduleActivity, true);
                        } else {
                          undoEdit(scheduleActivity, true);
                        }
                      },
                      child:
                          (activities[index].nextActivityAfter.inSeconds != 0)
                              ? RestTaskWithDuration(
                                  taskText:
                                      "${activities[index].activityDone ? 'Schedule Ended ' : 'Schedule will end '}${TransformFunctions.durationToString(scheduleActivity.nextActivityAfter)}.",
                                )
                              : const RestTask(taskText: "End")),
              ],
            );
          },
        );
      },
    );
  }
}
