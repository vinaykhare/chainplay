import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_activity_screen.dart';

class ActivitiesTimeline extends StatelessWidget {
  final Schedule tempSchedule;
  const ActivitiesTimeline({
    super.key,
    required this.tempSchedule,
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
        List<Activity> activities = snapshot.data as List<Activity>;
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
            Activity activity = activities[index];
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
                        'activities_dimissible_${activity.activityId}'),
                    onDismissed: (_) async {
                      await scheduleList.removeActivity(tempSchedule, activity);
                    },
                    child: ListTile(
                      tileColor: activity.activityDone
                          ? Colors.grey
                          : Theme.of(context).cardColor,
                      onTap: () async {
                        var updatedActivity = await Navigator.of(context)
                            .pushNamed(AddActivityScreen.routename,
                                arguments: activity);
                        if (updatedActivity != null) {
                          //replaceActivity(index, updatedActivity as Activity);
                          await scheduleList
                              .updateActivity(updatedActivity as Activity);
                        }
                      },
                      title: Text(activity.title),
                      subtitle: Text(
                        "will complete ${TransformFunctions.durationToString(activity.activityDuration)}.",
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      leading: Checkbox(
                        key: ValueKey('activities_checkbox_${activity.title}'),
                        value: activity.activityDone,
                        onChanged: (value) {
                          // setState(() {
                          //   activity.activityDone = value ?? false;
                          // });
                          scheduleList.flipDoneActivity(tempSchedule, activity);
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
                if (activities[index].nextActivityAfter.inSeconds != 0 &&
                    index != 0 &&
                    !activities[index - 1].activityDone)
                  Text(
                    "Rest will end ${TransformFunctions.durationToString(activity.nextActivityAfter)}.",
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
