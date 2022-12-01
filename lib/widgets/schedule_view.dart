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
                        if (schedule.at == null) {
                          await scheduleList.loadActivities(schedule);
                          schedule.edit = true;
                          await scheduleList.updateSchedule(schedule);
                          await nav.pushNamed(
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
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).cardColor,
                      title: Text(schedule.name),
                      subtitle: Text(DateFormat.yMEd()
                          .add_jms()
                          .format(schedule.lastUpdatedAt)),
                      leading: schedule.scheduleStatus == 0
                          ? CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).primaryColorLight,
                              child: IconButton(
                                onPressed: () async {
                                  if (schedule.at == null) {
                                    schedule.at = DateTime.now();
                                    await scheduleList.updateSchedule(schedule);
                                    // await scheduleList.scheduleNotification(
                                    //   schedule,
                                    //   schedule.at!,
                                    //   0,
                                    // );
                                  }
                                  await scheduleList.loadActivities(schedule);
                                  await scheduleList
                                      .cancelScheduleNotifications(schedule);
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
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).focusColor,
                              child: const Icon(Icons.done),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (schedule.scheduleStatus == 1 ||
                              schedule.at != null)
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
                                ? const Icon(Icons.favorite)
                                : const Icon(Icons.favorite_border_outlined),
                            onPressed: () async {
                              schedule.pinned = !schedule.pinned;
                              await scheduleList.updateSchedule(schedule);
                            },
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
