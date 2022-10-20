import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/schedule_screen.dart';

class ScheduleListScreen extends StatelessWidget {
  static String routename = "/schedules";

  const ScheduleListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedules"),
      ),
      body: ListView.builder(
        itemCount: scheduleList.schedules.length,
        itemBuilder: ((context, index) {
          return Container(
            padding: const EdgeInsets.all(5.0),
            child: Card(
              elevation: 5,
              child: Dismissible(
                key: ValueKey(scheduleList.schedules[index].name),
                onDismissed: (direction) {
                  scheduleList.removeSchedule(scheduleList.schedules[index]);
                },
                child: ListTile(
                  onTap: () => Navigator.of(context).pushNamed(
                    ScheduleScreen.routename,
                    arguments: scheduleList.schedules[index],
                  ),
                  title: Text(scheduleList.schedules[index].name),
                  subtitle: Text(
                    "At: ${DateFormat.yMEd().add_jms().format(scheduleList.schedules[index].at)}\n Duration: ${scheduleList.schedules[index].repeatAfter.toString()}",
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        PlaySchedule.routename,
                        arguments: scheduleList.schedules[index],
                      ),
                      icon: const Icon(Icons.play_arrow),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                      AddScheduleScreen.routename,
                      arguments: scheduleList.schedules[index],
                    ),
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ),
            ),
          );
        }),
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
