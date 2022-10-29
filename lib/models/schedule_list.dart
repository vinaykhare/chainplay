import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/db_helper.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';

class ScheduleList with ChangeNotifier {
  List<Schedule> schedules = [];

  addSchedule(Schedule schedule, String oldScheduleName) {
    int index =
        schedules.indexWhere((element) => element.name == schedule.name);

    if (index == -1) {
      schedules.add(schedule);
    } else {
      schedules[index] = schedule;
      removeSchedule(schedule, oldScheduleName);
    }

    for (var activity in schedule.activities) {
      // if (activity.syncedWithDb) {
      //   continue;
      // }
      DBHelper.insert("activity", {
        "activityId": activity.activityId,
        "title": activity.title,
        "activityDuration": activity.activityDuration.inSeconds,
        "nextActivityAfter ": activity.nextActivityAfter.inSeconds,
        "scheduleName": schedule.name,
      });
      //activity.syncedWithDb = true;
    }
    notifyListeners();
  }

  removeSchedule(Schedule schedule, [String oldScheduleName = ""]) {
    schedules.removeWhere((sc) => sc.name == schedule.name);
    DBHelper.removeData("activity", "scheduleName = ?", [schedule.name]);
    if (schedule.name != oldScheduleName) {
      DBHelper.removeData("activity", "scheduleName = ?", [oldScheduleName]);
    }
    notifyListeners();
  }

  getScheduleByName(String scheduleName) {
    return schedules.firstWhere((element) => scheduleName == element.name,
        orElse: () => Schedule());
  }

  fetchAllSchedules() async {
    List<Map<String, dynamic>> loadedActivities =
        await DBHelper.getData("activity");
    Map<String, List<Activity>> mappedActivities = {};
    for (var activity in loadedActivities) {
      if (mappedActivities[activity["scheduleName"]] == null) {
        mappedActivities[activity["scheduleName"]] = [];
      }
      mappedActivities[activity["scheduleName"]]!.add(Activity(
        title: activity["title"],
        activityDuration: Duration(seconds: activity["activityDuration"]),
        nextActivityAfter: Duration(seconds: activity["nextActivityAfter"]),
        //syncedWithDb: true,
      ));
    }

    schedules = mappedActivities.entries.map((entry) {
      Schedule schedule = Schedule();
      schedule.name = entry.key;
      schedule.activities = entry.value;
      return schedule;
    }).toList();
  }
}
