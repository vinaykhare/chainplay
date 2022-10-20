import 'package:flutter/material.dart';
import 'package:schedule_it/models/schedule.dart';

class ScheduleScreen extends StatelessWidget {
  static String routename = "/schedule";
  @override
  Widget build(BuildContext context) {
    Schedule schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
    return Scaffold(
      appBar: AppBar(
        title: Text(schedule.name),
      ),
      body: Column(
        children: [
          const Text("Activities"),
          SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: schedule.activities.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 10,
                  child: ListTile(
                    title: Text(schedule.activities[index].title),
                    subtitle: Text(schedule
                        .activities[index].activityDuration.inSeconds
                        .toString()),
                    trailing: Text(schedule
                        .activities[index].nextActivityAfter.inSeconds
                        .toString()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
