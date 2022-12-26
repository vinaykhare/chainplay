import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';

//import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/widgets/schedule_view.dart';

class ScheduleListItem extends StatelessWidget {
  //final BannerAd? adSchedule;
  final Schedule schedule;
  final bool showHistory, allowFlag;
  final int index;

  const ScheduleListItem({
    super.key,
    //this.adSchedule,
    required this.schedule,
    required this.showHistory,
    required this.allowFlag,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    return Dismissible(
      background: Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: BoxDecoration(
          color: Theme.of(context).errorColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.delete),
            Icon(Icons.delete),
          ],
        ),
      ),
      key: ValueKey("schedule_list_dismissible_${schedule.name}"),
      onDismissed: (direction) async {
        await scheduleList.removeSchedule(schedule);
      },
      // Expanded(
      //   child: ScheduleActivityListView(schedule: schedule),
      // ),
      child: ScheduleView(
        schedule: schedule,
        showHistory: showHistory,
        allowFlag: allowFlag,
        key: key,
        index: index,
      ),
    );
  }
}
