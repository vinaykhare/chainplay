import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/activity_view.dart';
import 'package:schedule_it/widgets/app_drawer.dart';

class ActivityListScreen extends StatefulWidget {
  static String routename = "/activities";

  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  @override
  Widget build(BuildContext context) {
    //ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    return Scaffold(
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<ScheduleList>(context).fetchActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Activity> activities = snapshot.data as List<Activity>;
            activities = activities.reversed.toList();
            // final pinnedSchedules =
            //     schedules.where((schedule) => schedule.pinned == true).toList();
            //final otherSchedules = schedules.where((schedule) => schedule.pinned != true).toList();
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        Activity activity = activities[index];
                        return ActivityView(
                          activity: activity,
                        );
                      },
                    ),
                  ),
                  AppBar(
                    centerTitle: true,
                    title: const Text("Activities"),
                    actions: [
                      IconButton(
                          onPressed:
                              Provider.of<ScheduleList>(context).clearDataBase,
                          icon: const Icon(Icons.clear))
                    ],
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
