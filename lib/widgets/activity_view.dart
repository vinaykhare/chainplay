import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule_list.dart';

class ActivityView extends StatelessWidget {
  final Activity activity;

  const ActivityView({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    return Dismissible(
      key: ValueKey(activity.activityId),
      onDismissed: (direction) {
        scheduleList.removeActivity(activity);
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        //key: ValueKey("schedule_list_container_${schedule.name}"),
        child: Card(
            elevation: 5,
            child: ListTile(
              onTap: () {},
              title: Text(activity.title),
              subtitle: Text(
                "Created on ${DateFormat.yMd().add_jms().format(activity.createdAt)}",
                //activity.activityId,
              ),
            )),
      ),
    );
  }
}
