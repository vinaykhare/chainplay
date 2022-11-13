import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:schedule_it/helpers/ad_state.dart';
import 'package:schedule_it/helpers/db_helper.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';

class ScheduleList with ChangeNotifier {
  List<Schedule> schedules = [];
  List<int> adIndexInSchedules = [];
  final AdState adState;
  final BuildContext context;

  ScheduleList(
    this.context,
    this.adState,
  );

  addSchedule(
      Schedule schedule, String oldScheduleName, Activity activity) async {
    int index =
        schedules.indexWhere((element) => element.name == schedule.name);

    // if (index == -1) {
    //   schedules.add(schedule);
    // } else {
    //   //schedules[index] = schedule;
    //   removeSchedule(oldScheduleName);
    // }

    //maxScheduleIndex = (await DBHelper.getMax("Activity", "scheduleIndex")) as int;
    int activityIndex =
        schedule.activities.isEmpty ? 0 : schedule.activities.length - 1;
    //for (var activity in schedule.activities) {
    // if (activity.syncedWithDb) {
    //   continue;
    // }
    DBHelper.insert(
      "activity",
      {
        "activityId": activity.activityId,
        "title": activity.title,
        "activityDuration": activity.activityDuration.inSeconds,
        "nextActivityAfter ": activity.nextActivityAfter.inSeconds,
      },
    );
    DBHelper.insert(
      "schedule",
      {
        "scheduleName": schedule.name,
        "lastUpdatedAt": schedule.lastUpdatedAt.millisecondsSinceEpoch,
        "pinned": schedule.pinned ? 1 : 0,
        "scheduleIndex": index == -1 ? schedules.length : index
      },
    );
    DBHelper.insert(
      "schedule_activity",
      {
        "scheduleName": schedule.name,
        "activityId": activity.activityId,
        "activityIndex": activityIndex,
        "activityDone": activity.activityDone ? 1 : 0,
      },
    );
    // }
    notifyListeners();
  }

  removeSchedule(Schedule schedule) {
    //schedules.removeWhere((sc) => sc.name == schedule.name);

    DBHelper.removeData(
      "schedule_activity",
      "scheduleName = ?",
      [schedule.name],
    );
    DBHelper.removeData(
      "schedule",
      "scheduleName = ?",
      [schedule.name],
    );

    for (Activity acitivty in schedule.activities) {
      DBHelper.removeData(
        "activity",
        "activityId = ?",
        [acitivty.activityId],
      );
    }
    notifyListeners();
  }

  removeActivity(Schedule schedule, Activity activity) {
    //schedules.removeWhere((sc) => sc.name == schedule.name);

    DBHelper.removeData(
      "schedule_activity",
      "activityId = ?",
      [activity.activityId],
    );

    DBHelper.removeData(
      "activity",
      "activityId = ?",
      [activity.activityId],
    );

    schedule.activities.removeWhere(
        (activityArg) => activityArg.activityId == activity.activityId);

    updateActivityIndex(schedule);

    notifyListeners();
  }

  updateActivity(Activity activity) {
    DBHelper.update(
      "activity",
      {
        "title": activity.title,
        "activityDuration": activity.activityDuration.inSeconds,
        "nextActivityAfter": activity.nextActivityAfter.inSeconds,
      },
      "activityId = ?",
      [activity.activityId],
    );
    notifyListeners();
  }

  /* Just for testing */
  clearDataBase() async {
    await DBHelper.removeData('activity', "", []);
    await DBHelper.removeData('schedule_activity', "", []);
    await DBHelper.removeData('schedule', "", []);
    notifyListeners();
  }

  rearrangeSchedules(int oldIndex, int newIndex) {}

  rearrangeActivites(Schedule schedule, int oldIndex, int newIndex) {
    // if (oldIndex == newIndex) {
    //   return;
    // }

    if (oldIndex > newIndex) {
      newIndex += 1;
    }

    var itemAtOldIndex = schedule.activities.removeAt(oldIndex);
    schedule.activities.insert(newIndex, itemAtOldIndex);
    updateActivityIndex(schedule);
    notifyListeners();
  }

  updateActivityIndex(Schedule schedule) {
    int dbIndex = 0;
    for (Activity activity in schedule.activities) {
      DBHelper.update(
        "schedule_activity",
        {
          "activityIndex": dbIndex,
        },
        "scheduleName = ? and activityId = ?",
        [schedule.name, activity.activityId],
      );
      dbIndex++;
    }
  }

  flipDoneActivity(Activity activity) {
    DBHelper.update(
      "schedule_activity",
      {
        "activityDone": activity.activityDone ? 0 : 1,
      },
      "activityId = ?",
      [activity.activityId],
    );
    notifyListeners();
  }

  pinSchedule(Schedule schedule) {
    schedule.pinned = !schedule.pinned;
    DBHelper.update(
      "schedule",
      {
        "pinned": schedule.pinned ? 1 : 0,
      },
      "scheduleName = ?",
      [schedule.name],
    );
    notifyListeners();
  }

  disposeAds() {
    for (int i = 0; i < adIndexInSchedules.length; i++) {
      schedules[adIndexInSchedules[i]].dispose();
    }
  }

  loadActivities(Schedule schedule) async {
    List<Map<String, dynamic>> loadedScheduleActivity =
        await DBHelper.getDataBySQL(
      '''
      SELECT schedule_activity.*, activity.*
      FROM schedule_activity
      JOIN activity ON (schedule_activity.activityId = activity.activityId)
      WHERE schedule_activity.scheduleName = ?
      ORDER BY schedule_activity.activityIndex
      ''',
      [schedule.name],
    );
    schedule.activities = [];
    for (var activity in loadedScheduleActivity) {
      Activity tempActivity = Activity(
        activityId: activity['activityId'],
        title: activity['title'],
        activityDone: activity['activityDone'] == 1,
        activityDuration: Duration(seconds: activity['activityDuration']),
        nextActivityAfter: Duration(seconds: activity['nextActivityAfter']),
      );
      schedule.activities.insert(activity['activityIndex'], tempActivity);
    }
    return schedule.activities;
  }

  fetchSchedules() async {
    List<Map<String, dynamic>> loadedSchedule =
        await DBHelper.getData("schedule", "pinned DESC, lastUpdatedAt DESC");
    schedules = [];
    for (var schedule in loadedSchedule) {
      Schedule tempSchedule = Schedule();
      tempSchedule.name = schedule["scheduleName"];
      if (schedule["startedAt"] != null) {
        tempSchedule.at =
            DateTime.fromMillisecondsSinceEpoch(schedule["startedAt"]);
      }

      if (schedule["lastUpdatedAt"] != null) {
        tempSchedule.lastUpdatedAt =
            DateTime.fromMillisecondsSinceEpoch(schedule["lastUpdatedAt"]);
      }

      tempSchedule.pinned = schedule["pinned"] == 1;

      schedules.add(tempSchedule);
    }

    //Add ads to Schedule
    adIndexInSchedules = [];
    for (var i = 1; i < schedules.length + 1; i += 5) {
      adIndexInSchedules.add(i);
      Schedule adSchedule = Schedule();
      adSchedule.name = "Sponsored..$i";
      adSchedule.adBanner = BannerAd(
        adUnitId: adState.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: adState.adListener,
      )..load();
      schedules.insert(i, adSchedule);
    }

    return schedules;
  }

  fetchActivities() async {
    List<Map<String, dynamic>> loadedActivities =
        await DBHelper.getData("activity", "activityId");

    List<Activity> activities = [];

    for (var activity in loadedActivities) {
      Activity tempActivity = Activity(
        activityId: activity["activityId"],
        title: activity["title"],
      );
      tempActivity.activityDuration =
          Duration(seconds: activity["activityDuration"] ?? 0);
      tempActivity.nextActivityAfter =
          Duration(seconds: activity["nextActivityAfter"] ?? 0);

      activities.insert(0, tempActivity);
    }

    return activities;
  }
}
