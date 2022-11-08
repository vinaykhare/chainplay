import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
    return Container(
      padding: const EdgeInsets.all(5.0),
      key: ValueKey("schedule_list_container_${schedule.name}"),
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
                  scheduleList.removeSchedule(schedule.name);
                },
                child: ListTile(
                  onTap: () => Navigator.of(context).pushNamed(
                    AddScheduleScreen.routename,
                    arguments: schedule,
                  ),
                  title: Text(schedule.name),
                  subtitle: Text(DateFormat.yMEd()
                      .add_jms()
                      .format(schedule.lastUpdatedAt)),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        PlaySchedule.routename,
                        arguments: schedule,
                      ),
                      icon: const Icon(Icons.play_arrow),
                    ),
                  ),
                  trailing: IconButton(
                    icon: schedule.pinned
                        ? const Icon(Icons.flag)
                        : const Icon(Icons.outlined_flag),
                    onPressed: () {
                      scheduleList.pinSchedule(schedule);
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
