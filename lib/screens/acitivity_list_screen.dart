import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/widgets/activity_view.dart';
import 'package:schedule_it/widgets/app_drawer.dart';

class ActivityListScreen extends StatelessWidget {
  static String routename = "/activities";

  const ActivityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Activities"),
        actions: [
          IconButton(
              onPressed: Provider.of<ScheduleList>(context).clearDataBase,
              icon: const Icon(Icons.clear))
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<ScheduleList>(context).fetchActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final activities = snapshot.data as List<Activity>;
            // final pinnedSchedules =
            //     schedules.where((schedule) => schedule.pinned == true).toList();
            //final otherSchedules = schedules.where((schedule) => schedule.pinned != true).toList();
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      Activity activity = activities[index];
                      return ActivityView(
                        activity: activity,
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddScheduleScreen.routename);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
