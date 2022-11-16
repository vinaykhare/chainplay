import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
//import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';

class ScheduleView extends StatelessWidget {
  final BannerAd? adSchedule;
  final Schedule schedule;

  const ScheduleView({super.key, this.adSchedule, required this.schedule});

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    NavigatorState nav = Navigator.of(context);
    return Container(
      padding: const EdgeInsets.all(5.0),
      key: key,
      child: Card(
        elevation: 5,
        child: adSchedule != null
            ? SizedBox(
                height: 50,
                child: AdWidget(ad: adSchedule!),
              )
            : Dismissible(
                background: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                  ),
                ),
                key: ValueKey("schedule_list_dismissible_${schedule.name}"),
                onDismissed: (direction) {
                  scheduleList.removeSchedule(schedule);
                },
                child: ListTile(
                  onTap: () async {
                    if (schedule.at == null) {
                      await Navigator.of(context).pushNamed(
                        AddScheduleScreen.routename,
                        arguments: schedule,
                      );
                    } else {
                      await scheduleList.loadActivities(schedule);
                      await nav.pushNamed(
                        PlaySchedule.routename,
                        arguments: schedule,
                      );
                    }
                  },
                  tileColor: schedule.scheduleStatus == 1
                      ? Colors.grey
                      : Theme.of(context).cardColor,
                  title: Text(schedule.name),
                  subtitle: Text(DateFormat.yMEd()
                      .add_jms()
                      .format(schedule.lastUpdatedAt)),
                  leading: schedule.scheduleStatus == 0
                      ? CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                            onPressed: () async {
                              if (schedule.at == null) {
                                schedule.at = DateTime.now();
                                await scheduleList.updateSchedule(schedule);
                              }
                              await scheduleList.loadActivities(schedule);
                              await nav.pushNamed(
                                PlaySchedule.routename,
                                arguments: schedule,
                              );
                            },
                            icon: schedule.at == null
                                ? const Icon(Icons.play_arrow)
                                : const Icon(Icons.directions_walk),
                          ),
                        )
                      : const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.done),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (schedule.scheduleStatus == 1 || schedule.at != null)
                        IconButton(
                          onPressed: () async {
                            schedule.at = null;
                            schedule.scheduleStatus = 0;
                            await scheduleList.updateSchedule(schedule);
                            await scheduleList.resetActivities(schedule);
                          },
                          icon: const Icon(Icons.restore),
                        ),
                      IconButton(
                        icon: schedule.pinned
                            ? const Icon(Icons.flag)
                            : const Icon(Icons.outlined_flag),
                        onPressed: () async {
                          await scheduleList.pinSchedule(schedule);
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
