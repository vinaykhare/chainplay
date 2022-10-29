import 'package:flutter/material.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/screens/add_activity_screen.dart';

class ActivitiesTimeline extends StatelessWidget {
  final Schedule tempSchedule;
  final Function? replaceActivity, removeActivity;
  const ActivitiesTimeline({
    super.key,
    required this.tempSchedule,
    required this.replaceActivity,
    required this.removeActivity,
  });

  String durationToString(Duration activityDuration) {
    String drStr = "for ";
    int activityDurationHour = activityDuration.inHours;
    if (activityDurationHour != 0) {
      drStr += "${activityDurationHour.toString().padLeft(2, '0')} Hours,";
    }
    int activityDurationMinute =
        activityDuration.inMinutes - (activityDurationHour * 60);
    int activityDurationSecond;
    if (activityDurationMinute == 0) {
      activityDurationSecond =
          activityDuration.inSeconds - (activityDurationHour * 3600);
    } else {
      drStr += "${activityDurationMinute.toString().padLeft(2, '0')} Minutes,";
      activityDurationSecond =
          activityDuration.inSeconds - (activityDurationMinute * 60);
    }

    if (activityDurationSecond != 0) {
      drStr += "${activityDurationSecond.toString().padLeft(2, '0')} Seconds,";
    }
    return drStr == "for " ? "Complete when done." : drStr;
  }

  @override
  Widget build(Object context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: true,
      onReorder: (oldIndex, newIndex) {
        if (newIndex >= tempSchedule.activities.length) {
          return;
        }
        var draggedActivity = tempSchedule.activities.removeAt(oldIndex);
        tempSchedule.activities.insert(newIndex, draggedActivity);
      },
      itemCount: tempSchedule.activities.length,
      itemBuilder: (context, index) {
        Activity activity = tempSchedule.activities[index];
        return Column(
          key: ValueKey(activity.activityId),
          children: [
            Container(
              width: 5,
              height: 15,
              decoration: const BoxDecoration(color: Colors.amber),
            ),
            Card(
              elevation: 10,
              child: ListTile(
                title: Text(activity.title),
                subtitle: replaceActivity != null
                    ? Text(
                        "${durationToString(activity.activityDuration)}.",
                      )
                    : null,
                trailing: replaceActivity != null
                    ? IconButton(
                        onPressed: () async {
                          Activity updatedActivity = await Navigator.of(context)
                              .pushNamed(AddActivityScreen.routename,
                                  arguments: activity) as Activity;
                          replaceActivity!(index, updatedActivity);
                        },
                        icon: const Icon(Icons.edit),
                      )
                    : Text(
                        "${durationToString(activity.activityDuration)}.",
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
                "Rest ${durationToString(activity.nextActivityAfter)}.",
              ),
          ],
        );
      },
    );
  }
}
