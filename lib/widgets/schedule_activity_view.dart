import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/app_drawer.dart';

class ScheduleActivityListView extends StatefulWidget {
  final Schedule schedule;
  const ScheduleActivityListView({super.key, required this.schedule});

  @override
  State<ScheduleActivityListView> createState() =>
      _ScheduleActivityListViewState();
}

class _ScheduleActivityListViewState extends State<ScheduleActivityListView> {
  @override
  Widget build(BuildContext context) {
    //ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<ScheduleList>(context).loadActivities(widget.schedule),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<ScheduleActivity> activities =
                snapshot.data as List<ScheduleActivity>;
            activities = activities.reversed.toList();
            // final pinnedSchedules =
            //     schedules.where((schedule) => schedule.pinned == true).toList();
            //final otherSchedules = schedules.where((schedule) => schedule.pinned != true).toList();
            return const SafeArea(
              child: ListTile(
                title: Text("Activities"),
              ),
            );
          }
        },
      ),
    );
  }
}
