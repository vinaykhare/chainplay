import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/transform_functions.dart';
import 'package:schedule_it/models/activity.dart';

class ActivityView extends StatelessWidget {
  final Activity activity;

  const ActivityView({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      //key: ValueKey("schedule_list_container_${schedule.name}"),
      child: Card(
          elevation: 5,
          child: ListTile(
            onTap: () {},
            title: Text(activity.title),
            subtitle: Text(
              "will complete ${TransformFunctions.durationToString(activity.activityDuration)}.",
              //activity.activityId,
            ),
          )),
    );
  }
}
