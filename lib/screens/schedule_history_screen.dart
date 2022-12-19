import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule_it/helpers/constants.dart';

import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/schedule_activities_history_screen.dart';

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
    List<Schedule> scheduleHistory = [];
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
                  Schedule scheduleExecution = scheduleHistory[index];
                  return InkWell(
                    onTap: () =>
                        scheduleExecution.scheduleStatus == statusExecuting
                            ? Navigator.of(context).pushNamed(
                                PlaySchedule.routename,
                                arguments: scheduleExecution,
                              )
                            : Navigator.of(context).pushNamed(
                                ScheduleActivitiesHistoryScreen.routename,
                                arguments: scheduleExecution,
                              ),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: RadialGradient(
                        colors: [
                          scheduleExecution.scheduleStatus == statusDone
                              ? Theme.of(context).backgroundColor
                              : Colors.blue,
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                      )),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: scheduleDate("Started At",
                                  scheduleExecution.at ?? DateTime.now()),
                            ),
                            const Icon(Icons.arrow_forward),
                            Expanded(
                              child: scheduleDate("Ended At",
                                  scheduleExecution.endedAt ?? DateTime.now()),
                            ),
                          ],
                        ),
                      ),
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
    );
  }
}
