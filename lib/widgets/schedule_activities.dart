import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/rest_task.dart';
import 'package:schedule_it/widgets/rest_task_with_duration.dart';

import 'package:schedule_it/widgets/schedule_activity_flow_view.dart';
import 'package:schedule_it/widgets/schedule_system_activity_flow_view.dart';
//import 'package:schedule_it/screens/add_schedule_activity_screen.dart';

class ScheduleActivities extends StatelessWidget {
  final Schedule tempSchedule;
  final Function? editActivity, undoEdit, addScheduleDateToSchedule;
  const ScheduleActivities({
    super.key,
    required this.tempSchedule,
    required this.editActivity,
    required this.undoEdit,
    this.addScheduleDateToSchedule,
  });

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);

    final Widget lineWidget = Container(
      width: 2,
      height: 15,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    );

    Widget arrowWidget = Icon(
      Icons.arrow_downward,
      color: Theme.of(context).primaryColor,
    );

    List<ScheduleActivity> activities = tempSchedule.activities;
    activities = activities.reversed.toList();

    Widget getScheduleActivityView(BuildContext context, int index) {
      ScheduleActivity scheduleActivity = activities[index];
      switch (scheduleActivity.activity.type) {
        case systemStartActivityInDB:
          return Column(
            key: Key(index.toString()),
            children: [
              GestureDetector(
                onLongPressMoveUpdate: (details) {},
                onTap: () async {
                  if (!scheduleActivity.edit) {
                    editActivity!(scheduleActivity, false);
                  } else {
                    undoEdit!(scheduleActivity, false);
                  }
                },
                child: tempSchedule.at != null
                    ? RestTaskWithDuration(
                        taskText:
                            "${tempSchedule.at!.isAfter(DateTime.now()) ? 'Scheduled to Start at' : 'Started on '} \n${DateFormat.yMd().add_jms().format(tempSchedule.at!)}",
                      )
                    : const RestTask(taskText: "Start"),
              ),
            ],
          );
        case systemWaitActivityInDB:
          return ScheduleSystemActivityFlowView(
            key: Key(index.toString()),
            activities: activities,
            arrowWidget: arrowWidget,
            scheduleActivity: scheduleActivity,
            scheduleList: scheduleList,
            tempSchedule: tempSchedule,
            editActivity: editActivity,
            undoEdit: undoEdit,
            lineWidget: lineWidget,
            index: index,
          );
        case waitActivityInDB:
        default:
          return ScheduleActivityFlowView(
            key: Key(index.toString()),
            activities: activities,
            arrowWidget: arrowWidget,
            scheduleActivity: scheduleActivity,
            scheduleList: scheduleList,
            tempSchedule: tempSchedule,
            editActivity: editActivity,
            undoEdit: undoEdit,
            lineWidget: lineWidget,
            index: index,
          );
      }
    }

    Widget getScheduleActivitySequence(BuildContext context, int index) {
      return Column(
        key: Key(index.toString()),
        children: [
          getScheduleActivityView(context, index),
        ],
      );
    }

    return IgnorePointer(
      ignoring: undoEdit == null || editActivity == null,
      child: ReorderableListView.builder(
        reverse: true,
        buildDefaultDragHandles: true,
        onReorder: (oldIndex, newIndex) {
          oldIndex = activities.length - oldIndex - 1;
          newIndex = activities.length - newIndex - 1;
          scheduleList.rearrangeActivites(tempSchedule, oldIndex, newIndex);
        },
        itemCount: activities.length,
        itemBuilder: (context, index) =>
            getScheduleActivitySequence(context, index),
      ),
    );
    // return editActivity == null
    //     ? ListView.builder(
    //         reverse: true,
    //         itemCount: activities.length,
    //         itemBuilder: (context, index) =>
    //             getScheduleActivitySequence(context, index),
    //       )
    //     : ReorderableListView.builder(
    //         reverse: true,
    //         buildDefaultDragHandles: true,
    //         onReorder: (oldIndex, newIndex) {
    //           oldIndex = activities.length - oldIndex - 1;
    //           newIndex = activities.length - newIndex - 1;
    //           scheduleList.rearrangeActivites(tempSchedule, oldIndex, newIndex);
    //         },
    //         itemCount: activities.length,
    //         itemBuilder: (context, index) =>
    //             getScheduleActivitySequence(context, index),
    //       );
  }
}
