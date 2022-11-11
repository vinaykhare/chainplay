import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/screens/add_activity_screen.dart';

class ActivitiesTimeline extends StatefulWidget {
  final Schedule tempSchedule;
  final Function replaceActivity, removeActivity;
  const ActivitiesTimeline({
    super.key,
    required this.tempSchedule,
    required this.replaceActivity,
    required this.removeActivity,
  });

  @override
  State<ActivitiesTimeline> createState() => _ActivitiesTimelineState();
}

class _ActivitiesTimelineState extends State<ActivitiesTimeline> {
  @override
  Widget build(Object context) {
    return ReorderableListView.builder(
      reverse: true,
      buildDefaultDragHandles: true,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        var itemAtOldIndex = widget.tempSchedule.activities.removeAt(oldIndex);
        widget.tempSchedule.activities.insert(newIndex, itemAtOldIndex);
      },
      itemCount: widget.tempSchedule.activities.length,
      itemBuilder: (context, index) {
        Activity activity = widget.tempSchedule.activities[index];
        return Column(
          key: ValueKey(activity.activityId),
          children: [
            if (index == widget.tempSchedule.activities.length - 1)
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
                key: ValueKey(widget.tempSchedule.activities[index].activityId),
                onDismissed: (_) {
                  widget.removeActivity(index);
                },
                child: ListTile(
                  tileColor: activity.activityDone
                      ? Colors.grey
                      : Theme.of(context).cardColor,
                  onTap: () async {
                    var updatedActivity = await Navigator.of(context).pushNamed(
                        AddActivityScreen.routename,
                        arguments: activity);
                    if (updatedActivity != null) {
                      widget.replaceActivity(
                          index, updatedActivity as Activity);
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
                    key: ValueKey(activity.title),
                    value: activity.activityDone,
                    onChanged: (value) {
                      setState(() {
                        activity.activityDone = value ?? false;
                      });
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
            if (widget.tempSchedule.activities[index].nextActivityAfter
                        .inSeconds !=
                    0 &&
                index != 0 &&
                !widget.tempSchedule.activities[index - 1].activityDone)
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
