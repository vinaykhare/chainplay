import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';

import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/widgets/schedule_view.dart';
import 'package:schedule_it/widgets/time_summary.dart';

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
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: true);
    List<Schedule> scheduleHistory = [];
    if (ModalRoute.of(context)?.settings.arguments != null) {
      Schedule scheduleArg =
          ModalRoute.of(context)?.settings.arguments as Schedule;
      schedule = scheduleList.schedules
          .firstWhere((sch) => sch.name == scheduleArg.name);

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
              child: scheduleHistory.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "This Schedule is not executed yet!!\nPlay now",
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            child: IconButton(
                              onPressed: () async {
                                NavigatorState nav = Navigator.of(context);
                                Schedule scheduleExecution =
                                    await Provider.of<ScheduleList>(context,
                                            listen: false)
                                        .startScheduleExecution(schedule);
                                //await scheduleList.loadActivities(schedule);

                                await nav.pushNamed(PlaySchedule.routename,
                                    arguments: {
                                      payLoadSchduleExecId:
                                          scheduleExecution.scheduleExecutionId,
                                      payLoadSchduleName:
                                          scheduleExecution.name,
                                      payLoadScheduleActivityIndex:
                                          scheduleHistory.length - 1, //0
                                      payLoadScheduleActivityCount:
                                          scheduleHistory.length,
                                    });
                              },
                              icon: schedule.scheduleStatus == statusExecuting
                                  ? const Icon(Icons.directions_walk)
                                  : const Icon(Icons.play_arrow),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      reverse: true,
                      // onReorder: (oldIndex, newIndex) =>
                      //     Provider.of<ScheduleList>(context, listen: false)
                      //         .rearrangeSchedules(oldIndex, newIndex),
                      itemCount: scheduleHistory.length,
                      itemBuilder: (context, index) {
                        Schedule scheduleExecution = scheduleHistory[index];
                        int numberOfUserActivites = scheduleExecution.activities
                            .where((schEx) =>
                                schEx.activity.type == waitActivityInDB)
                            .length;
                        return Column(
                          children: [
                            if (index == scheduleHistory.length - 1)
                              const Text("Executed Schedule"),
                            InkWell(
                              onTap: () =>
                                  Navigator.of(context).pushReplacementNamed(
                                PlaySchedule.routename,
                                arguments: {
                                  payLoadSchduleExecId:
                                      scheduleExecution.scheduleExecutionId,
                                  payLoadSchduleName: scheduleExecution.name,
                                  payLoadScheduleActivityIndex: index,
                                  payLoadScheduleActivityCount:
                                      scheduleHistory.length,
                                },
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                  colors: [
                                    Theme.of(context).backgroundColor,
                                    Theme.of(context).scaffoldBackgroundColor,
                                  ],
                                )),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: (scheduleExecution.endedAt != null)
                                      ? /* Row(
                                          children: [
                                            Expanded(
                                              child: scheduleDate(
                                                  scheduleExecution.endedAt !=
                                                          null
                                                      ? "Started At"
                                                      : "Running",
                                                  scheduleExecution.at ??
                                                      DateTime.now()),
                                            ),
                                            const Icon(Icons.arrow_forward),
                                            Expanded(
                                              child: scheduleDate("Ended At",
                                                  scheduleExecution.endedAt!),
                                            ),
                                          ],
                                        ) */
                                      TimeSummary(
                                          cardTitle: null,
                                          startTime: scheduleExecution.at,
                                          endTime: scheduleExecution.endedAt,
                                          textInBetween:
                                              "$numberOfUserActivites",
                                        )
                                      : Column(
                                          children: [
                                            const Text("Running Schedule"),
                                            ScheduleView(
                                              schedule: schedule,
                                              showHistory: false,
                                              allowFlag: false,
                                              key: Key(
                                                index.toString(),
                                              ),
                                              index: index,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
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
