import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';

import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/schedule_history_screen.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:intl/intl.dart';

class ScheduleView extends StatelessWidget {
  final Schedule schedule;
  final bool showHistory, allowFlag;
  final int index;

  const ScheduleView(
      {required super.key,
      required this.schedule,
      required this.showHistory,
      required this.allowFlag,
      required this.index});

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    NavigatorState nav = Navigator.of(context);
    return Card(
      key: key,
      elevation: 10,
      child: ListTile(
        onTap: () async {
          NavigatorState nav = Navigator.of(context);
          if (schedule.scheduleStatus == statusNotStarted) {
            //await scheduleList.loadActivities(schedule);
            schedule.edit = true;
            await scheduleList.updateSchedule(schedule);
            await nav.pushNamed(
              AddScheduleScreen.routename,
              arguments: schedule,
            );
          } else {
            Schedule scheduleExecution =
                await scheduleList.startScheduleExecution(schedule);
            //await scheduleList.loadActivities(schedule);
            await nav.pushNamed(
              PlaySchedule.routename,
              arguments: {
                payLoadSchduleExecId: scheduleExecution.scheduleExecutionId,
                payLoadSchduleName: scheduleExecution.name,
                payLoadScheduleActivityIndex: index, //0
                payLoadScheduleActivityCount: schedule.scheduleHistory.length,
              },
            );
          }
        },
        tileColor: schedule.scheduleStatus == statusDone
            ? Theme.of(context).disabledColor
            : Theme.of(context).cardColor,
        title: Text(schedule.name),
        subtitle: Text(
          'Last Updated: ${DateFormat.yMEd().add_jms().format(schedule.lastUpdatedAt)}',
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColorLight,
          child: IconButton(
            onPressed: () async {
              if (schedule.scheduleStatus == statusExecuting) {
                await scheduleList.stopScheduleExecution(schedule);
              } else {
                //await scheduleList.loadActivities(schedule);
                Schedule scheduleExecution =
                    await scheduleList.startScheduleExecution(schedule);
                await nav.pushNamed(
                  PlaySchedule.routename,
                  arguments: {
                    payLoadSchduleExecId: scheduleExecution.scheduleExecutionId,
                    payLoadSchduleName: scheduleExecution.name,
                    payLoadScheduleActivityIndex: index, //0
                    payLoadScheduleActivityCount:
                        schedule.scheduleHistory.length,
                  },
                );
              }
            },
            icon: schedule.scheduleStatus == statusExecuting
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowFlag)
              IconButton(
                icon: schedule.pinned
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border_outlined),
                onPressed: () async {
                  schedule.pinned = !schedule.pinned;
                  await scheduleList.updateSchedule(schedule);
                },
              ),
            if (showHistory)
              IconButton(
                onPressed: () async {
                  Navigator.of(context).pushNamed(
                    ScheduleHistoryScreen.routename,
                    arguments: schedule,
                  );
                },
                icon: const Icon(Icons.arrow_forward),
              ),
          ],
        ),
      ),
    );
  }
}
