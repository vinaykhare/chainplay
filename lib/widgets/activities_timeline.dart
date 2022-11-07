import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/screens/add_activity_screen.dart';

class ActivitiesTimeline extends StatelessWidget {
  final Schedule tempSchedule;
  final Function replaceActivity, removeActivity;
  const ActivitiesTimeline({
    super.key,
    required this.tempSchedule,
    required this.replaceActivity,
    required this.removeActivity,
  });

  @override
  Widget build(Object context) {
    return ReorderableListView.builder(
      reverse: true,
      buildDefaultDragHandles: true,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        var itemAtOldIndex = tempSchedule.activities.removeAt(oldIndex);
        tempSchedule.activities.insert(newIndex, itemAtOldIndex);
      },
      itemCount: tempSchedule.activities.length,
      itemBuilder: (context, index) {
        Activity activity = tempSchedule.activities[index];
        return Column(
          key: ValueKey(activity.activityId),
          children: [
            if (index == tempSchedule.activities.length - 1)
              const Text("Start"),
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
                key: ValueKey(tempSchedule.activities[index].activityId),
                onDismissed: (_) {
                  removeActivity(index);
                },
                child: ListTile(
                  onTap: () async {
                    var updatedActivity = await Navigator.of(context).pushNamed(
                        AddActivityScreen.routename,
                        arguments: activity);
                    if (updatedActivity != null) {
                      replaceActivity(index, updatedActivity as Activity);
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
                ),
              ),
            ),
            Container(
              width: 5,
              height: 15,
              decoration: const BoxDecoration(color: Colors.amber),
            ),
            if (tempSchedule.activities[index].nextActivityAfter.inSeconds != 0)
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
  }
}
