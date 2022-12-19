import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';
//import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/schedule_history_screen.dart';

class ScheduleView extends StatelessWidget {
  //final BannerAd? adSchedule;
  final Schedule schedule;

  const ScheduleView({
    super.key,
    //this.adSchedule,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    NavigatorState nav = Navigator.of(context);
    return Container(
      padding: const EdgeInsets.all(5.0),
      key: key,
      child: Card(
        elevation: 5,
        child:
            // adSchedule != null
            //     ?
            //     SizedBox(
            //         height: 50,
            //         child: AdWidget(ad: adSchedule!),
            //       )
            //     :
            Dismissible(
          background: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).errorColor,
            ),
          ),
          key: ValueKey("schedule_list_dismissible_${schedule.name}"),
          onDismissed: (direction) async {
            await scheduleList.removeSchedule(schedule);
          },
          // Expanded(
          //   child: ScheduleActivityListView(schedule: schedule),
          // ),
          child: Column(
            children: [
              ListTile(
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
                      arguments: scheduleExecution,
                    );
                  }
                },
                tileColor: schedule.scheduleStatus == statusDone
                    ? Theme.of(context).disabledColor
                    : Theme.of(context).cardColor,
                title: Text(schedule.name),
                subtitle: Text(
                    DateFormat.yMEd().add_jms().format(schedule.lastUpdatedAt)),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: IconButton(
                    onPressed: () async {
                      Schedule scheduleExecution =
                          await scheduleList.startScheduleExecution(schedule);
                      //await scheduleList.loadActivities(schedule);

                      await nav.pushNamed(
                        PlaySchedule.routename,
                        arguments: scheduleExecution,
                      );
                    },
                    icon: schedule.scheduleStatus == statusExecuting
                        ? const Icon(Icons.directions_walk)
                        : const Icon(Icons.play_arrow),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: schedule.pinned
                          ? const Icon(Icons.favorite)
                          : const Icon(Icons.favorite_border_outlined),
                      onPressed: () async {
                        schedule.pinned = !schedule.pinned;
                        await scheduleList.updateSchedule(schedule);
                      },
                    ),
                    if (schedule.scheduleHistory.isNotEmpty)
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
              //ScheduleActivityListView(schedule: schedule),
            ],
          ),
        ),
      ),
    );
  }
}
