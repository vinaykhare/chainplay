import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_execution.dart';

//import 'package:schedule_it/widgets/app_drawer.dart';

class ScheduleHistoryScreen extends StatelessWidget {
  static String routename = "/schedule_history";

  const ScheduleHistoryScreen({super.key});

  // late ScheduleList scheduleList;
  // List<Schedule> schedules = [];

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   scheduleList = Provider.of<ScheduleList>(context, listen: true);
  //   // scheduleList.fetchSchedules().then((value) {
  //   //   setState(() {
  //   //     schedules = value;
  //   //   });
  //   // });
  // }

  Text headerText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Text contentText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
      ),
    );
  }

  Card scheduleDate(String title, DateTime schDate) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            headerText(title),
            const Divider(
              thickness: 1,
            ),
            contentText(
              DateFormat.yMEd().format(
                schDate,
              ),
            ),
            contentText(
              DateFormat.jms().format(
                schDate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Schedule schedule = Schedule();
    List<ScheduleExecution> scheduleHistory = [];
    if (ModalRoute.of(context)?.settings.arguments != null) {
      schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
      scheduleHistory = schedule.scheduleHistory;
      //tempSchedule.loadActivities();
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                // onReorder: (oldIndex, newIndex) =>
                //     Provider.of<ScheduleList>(context, listen: false)
                //         .rearrangeSchedules(oldIndex, newIndex),
                itemCount: scheduleHistory.length,
                itemBuilder: (context, index) {
                  ScheduleExecution scheduleExecution = scheduleHistory[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: scheduleDate("Started At",
                              scheduleExecution.startedAt ?? DateTime.now()),
                        ),
                        const Icon(Icons.arrow_forward),
                        Expanded(
                          child: scheduleDate("Ended At",
                              scheduleExecution.endedAt ?? DateTime.now()),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            AppBar(
              centerTitle: true,
              title: Text(schedule.name),
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).pushNamed(AddScheduleScreen.routename);
      //   },
      //   child: const Icon(
      //     Icons.add,
      //   ),
      // ),
    );
  }
}
