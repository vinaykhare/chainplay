import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';

import 'package:schedule_it/widgets/schedule_activity_flow_view.dart';
import 'package:schedule_it/widgets/schedule_system_activity_flow_view.dart';
//import 'package:schedule_it/screens/add_schedule_activity_screen.dart';

class ScheduleActivities extends StatelessWidget {
  final Schedule tempSchedule;
  final Function? editActivity, undoEdit;
  final bool showCheckBoxes;
  const ScheduleActivities({
    super.key,
    required this.tempSchedule,
    required this.editActivity,
    required this.undoEdit,
    required this.showCheckBoxes,
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
            showCheckBox: showCheckBoxes,
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
            showCheckBox: showCheckBoxes,
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

    return editActivity == null
        ? ListView.builder(
            reverse: true,
            itemCount: activities.length,
            itemBuilder: (context, index) =>
                getScheduleActivitySequence(context, index),
          )
        : ReorderableListView.builder(
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
          );
  }
}
