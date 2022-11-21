import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
//import 'package:schedule_it/screens/add_schedule_activity_screen.dart';

class ActivitiesTimeline extends StatelessWidget {
  final Schedule tempSchedule;
  final Function editActivity;
  const ActivitiesTimeline({
    super.key,
    required this.tempSchedule,
    required this.editActivity,
  });

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);
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
                if (index == activities.length - 1) const Text("Start"),
                Container(
                  width: 5,
                  height: 15,
                  decoration: const BoxDecoration(color: Colors.amber),
                ),
                Card(
                  elevation: 10,
                  child: Dismissible(
                    background: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                      ),
                    ),
                    key: ValueKey(
                        'activities_dimissible_${scheduleActivity.activity.activityId}'),
                    onDismissed: (_) async {
                      await scheduleList.removeActivityFromSchedule(
                          tempSchedule, scheduleActivity);
                    },
                    child: ListTile(
                      tileColor: scheduleActivity.activityDone
                          ? Colors.grey
                          : Theme.of(context).cardColor,
                      onTap: () async {
                        // var updatedActivity = await Navigator.of(context)
                        //     .pushNamed(AddScheduleActivityScreen.routename,
                        //         arguments: scheduleActivity);
                        // if (updatedActivity != null) {
                        //   //replaceActivity(index, updatedActivity as Activity);
                        //   await scheduleList.updateScheduleActivityByActivityId(
                        //     tempSchedule,
                        //     updatedActivity as ScheduleActivity,
                        //   );
                        //   await scheduleList
                        //       .updateActivity(updatedActivity.activity);
                        // }
                        editActivity(scheduleActivity, false);
                      },
                      title: Text(scheduleActivity.activity.title),
                      subtitle: Text(
                        "will complete ${TransformFunctions.durationToString(scheduleActivity.activityDuration)}.",
                      ),
                      trailing: ReorderableDragStartListener(
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
                Container(
                  width: 5,
                  height: 15,
                  decoration: const BoxDecoration(color: Colors.amber),
                ),
                InkWell(
                  onTap: () {
                    editActivity(scheduleActivity, true);
                  },
                  child: (activities[index].nextActivityAfter.inSeconds != 0 &&
                          index != 0 &&
                          !activities[index - 1].activityDone)
                      ? Text(
                          "Rest will end ${TransformFunctions.durationToString(scheduleActivity.nextActivityAfter)}.",
                        )
                      : const Icon(
                          Icons.circle_outlined,
                          size: 15,
                          color: Colors.amber,
                        ),
                ),
                if (index == 0)
                  Container(
                    width: 5,
                    height: 15,
                    decoration: const BoxDecoration(color: Colors.amber),
                  ),
                if (index == 0) const Text("End"),
              ],
            );
          },
        );
      },
    );
  }
}
