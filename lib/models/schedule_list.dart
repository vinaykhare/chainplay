import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:schedule_it/helpers/ad_state.dart';
import 'package:schedule_it/helpers/db_helper.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';

/*

Table of Content for Functions defined in this class
Schedule:
	addSchedule
	removeSchedule
	-> updateSchdule
	rearrangeSchedules
	pinSchedule
	fetchSchedules

Activity:
	-> addActivity .. no need as of now.
	removeActivity
	updateActivity
	rearrangeActivites
	updateActivityIndex
	flipDoneActivity
	loadActivities
	fetchActivities

Util:
	clearDataBase
	disposeAds

*/

class ScheduleList with ChangeNotifier {
  List<Schedule> schedules = [];
  List<int> adIndexInSchedules = [];
  final AdState adState;
  final BuildContext context;

  ScheduleList(
    this.context,
    this.adState,
  );

  addSchedule(Schedule schedule, Activity activity) async {
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
        "scheduleIndex": index == -1 ? schedules.length : index,
        "scheduleStatus": schedule.scheduleStatus,
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

  renameSchedule(String oldScheduleName, String newScheduleName) async {
    await DBHelper.update(
      "schedule",
      {
        "scheduleName": newScheduleName,
      },
      "scheduleName = ?",
      [oldScheduleName],
    );

    await DBHelper.update(
      "schedule_activity",
      {
        "scheduleName": newScheduleName,
      },
      "scheduleName = ?",
      [oldScheduleName],
    );

    notifyListeners();
  }

  updateSchedule(Schedule schedule) {
    DBHelper.update(
      "schedule",
      {
        "startedAt":
            schedule.at != null ? schedule.at!.millisecondsSinceEpoch : -1,
        "lastUpdatedAt": DateTime.now().millisecondsSinceEpoch,
        "scheduleStatus": schedule.scheduleStatus,
      },
      "scheduleName = ?",
      [schedule.name],
    );
  }

  completeScheduleActivity(Schedule schedule) {
    DBHelper.update(
      "schedule_activity",
      {
        "activityDone": 1,
      },
      "scheduleName = ?",
      [schedule.name],
    );
  }

  resetActivities(Schedule schedule) {
    DBHelper.update(
      "schedule_activity",
      {
        "activityDone": 0,
      },
      "scheduleName = ?",
      [schedule.name],
    );
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
  }

  rearrangeSchedules(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var itemAtOldIndex = schedules.removeAt(oldIndex);
    schedules.insert(newIndex, itemAtOldIndex);

    updateScheduleIndex();
    notifyListeners();
  }

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

  updateScheduleIndex() {
    int dbIndex = 0;
    for (Schedule schedule in schedules) {
      if (schedule.adBanner != null) {
        continue;
      }
      DBHelper.update(
        "schedule",
        {
          "scheduleIndex": dbIndex,
        },
        "scheduleName = ?",
        [schedule.name],
      );
      dbIndex++;
    }
  }

  bool allActivitiesDone(Schedule schedule) {
    bool allDone = true;
    for (int i = 0; i < schedule.activities.length; i++) {
      if (schedule.activities[i].activityDone == false) {
        allDone = false;
        break;
      }
    }
    //schedule.activities = [];
    return allDone;
  }

  flipDoneActivity(Schedule schedule, Activity activity) {
    activity.activityDone = !activity.activityDone;

    if (allActivitiesDone(schedule)) {
      schedule.scheduleStatus = 1;
    } else {
      schedule.scheduleStatus = 0;
    }

    DBHelper.update(
      "schedule_activity",
      {
        "activityDone": activity.activityDone ? 1 : 0,
      },
      "activityId = ?",
      [activity.activityId],
    );
    DBHelper.update(
      "schedule",
      {
        "scheduleStatus": schedule.scheduleStatus,
      },
      "scheduleName = ?",
      [schedule.name],
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
      //schedule.activities.insert(activity['activityIndex'], tempActivity);
      schedule.activities.add(tempActivity);
    }
    return schedule.activities;
  }

  fetchSchedules() async {
    List<Map<String, dynamic>> loadedSchedule = await DBHelper.getData(
        "schedule", "pinned, lastUpdatedAt, scheduleIndex DESC");
    schedules = [];
    for (var schedule in loadedSchedule) {
      Schedule tempSchedule = Schedule();
      tempSchedule.name = schedule["scheduleName"];
      if (schedule["startedAt"] != null && schedule["startedAt"] != -1) {
        tempSchedule.at =
            DateTime.fromMillisecondsSinceEpoch(schedule["startedAt"]);
      } else {
        tempSchedule.at = null;
      }

      if (schedule["lastUpdatedAt"] != null) {
        tempSchedule.lastUpdatedAt =
            DateTime.fromMillisecondsSinceEpoch(schedule["lastUpdatedAt"]);
      }

      tempSchedule.pinned = schedule["pinned"] == 1;
      tempSchedule.scheduleStatus = schedule["scheduleStatus"];
      //await loadActivities(tempSchedule);

      schedules.insert(0, tempSchedule);
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
