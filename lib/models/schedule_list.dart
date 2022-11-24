import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/constants.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:schedule_it/helpers/ad_state.dart';
import 'package:schedule_it/helpers/db_helper.dart';
import 'package:schedule_it/helpers/notifications/local_notification_service.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';

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
  //List<int> adIndexInSchedules = [];
  //final AdState adState;
  final BuildContext context;
  final LocalNotificationService localNotificationService;

  ScheduleList(
    this.context,
    this.localNotificationService,
    //this.adState,
  );

  addSchedule(Schedule schedule, ScheduleActivity scheduleActivity) async {
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
        "activityId": scheduleActivity.activity.activityId,
        "title": scheduleActivity.activity.title,
        "type": scheduleActivity.activity.type,
        "createdAt": scheduleActivity.activity.createdAt.millisecondsSinceEpoch,
        "lastUpdatedAt":
            scheduleActivity.activity.lastUpdatedAt.millisecondsSinceEpoch,
        "editActivity": scheduleActivity.activity.edit ? 1 : 0,
      },
    );
    DBHelper.insert(
      "schedule",
      {
        "scheduleName": schedule.name,
        "scheduleIndex": index == -1 ? schedules.length : index,
        "createdAt": schedule.createdAt.millisecondsSinceEpoch,
        "lastUpdatedAt": schedule.lastUpdatedAt.millisecondsSinceEpoch,
        "pinned": schedule.pinned ? 1 : 0,
        "scheduleStatus": schedule.scheduleStatus,
        "startedAt": schedule.at == null
            ? noValueInDB
            : schedule.at!.millisecondsSinceEpoch,
        "endedAt": schedule.endedAt == null
            ? noValueInDB
            : schedule.endedAt!.millisecondsSinceEpoch,
        "notificationId": schedule.notificationId,
        "editSchedule": 1,
      },
    );
    DBHelper.insert(
      "schedule_activity",
      {
        "scheduleName": schedule.name,
        "activityId": scheduleActivity.activity.activityId,
        "activityIndex": activityIndex,
        "activityDone": scheduleActivity.activityDone ? 1 : 0,
        "notificationId": scheduleActivity.notificationId,
        "activityDuration": scheduleActivity.activityDuration.inSeconds,
        "nextActivityAfter ": scheduleActivity.nextActivityAfter.inSeconds,
        "startedAt": scheduleActivity.at == null
            ? noValueInDB
            : scheduleActivity.at!.millisecondsSinceEpoch,
        "endedAt": scheduleActivity.endedAt == null
            ? noValueInDB
            : scheduleActivity.endedAt!.millisecondsSinceEpoch,
        "editScheduleActivity": scheduleActivity.edit ? 1 : 0,
        "editNextActivity": scheduleActivity.editNextActivity ? 1 : 0,
      },
    );
    // }
    notifyListeners();
  }

  removeSchedule(Schedule schedule) async {
    await cancelScheduleNotifications(schedule);

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

    // for (Activity acitivty in schedule.activities) {
    //   DBHelper.removeData(
    //     "activity",
    //     "activityId = ?",
    //     [acitivty.activityId],
    //   );
    // }
    notifyListeners();
  }

  Future<bool> nameExistInDB(String scheduleName) async {
    List<Map<String, dynamic>> result = await DBHelper.getDataBySQL(
        'Select scheduleName, editSchedule from schedule where editSchedule = 0 and scheduleName = ?',
        [scheduleName]);
    if (result.isNotEmpty && result[0]['scheduleName'] != "") {
      return true;
    }
    return false;
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
        "lastUpdatedAt": schedule.lastUpdatedAt.millisecondsSinceEpoch,
        "pinned": schedule.pinned,
        "startedAt": schedule.at != null
            ? schedule.at!.millisecondsSinceEpoch
            : noValueInDB,
        "endedAt": schedule.endedAt != null
            ? schedule.endedAt!.millisecondsSinceEpoch
            : noValueInDB,
        "scheduleStatus": schedule.scheduleStatus,
        "notificationId": schedule.notificationId,
        "editSchedule": schedule.edit ? 1 : 0,
      },
      "scheduleName = ?",
      [schedule.name],
    );
    notifyListeners();
  }

  updateScheduleActivityByActivityId(
      Schedule schedule, ScheduleActivity scheduleActivity) {
    DBHelper.update(
      "schedule_activity",
      {
        "activityDone": scheduleActivity.activityDone,
        "notificationId": scheduleActivity.notificationId,
        "activityDuration": scheduleActivity.activityDuration.inSeconds,
        "nextActivityAfter": scheduleActivity.nextActivityAfter.inSeconds,
        "startedAt": scheduleActivity.at != null
            ? scheduleActivity.at!.millisecondsSinceEpoch
            : -1,
        "endedAt": scheduleActivity.endedAt != null
            ? scheduleActivity.endedAt!.millisecondsSinceEpoch
            : -1,
        "editScheduleActivity": scheduleActivity.edit ? 1 : 0,
        "editNextActivity": scheduleActivity.editNextActivity ? 1 : 0,
      },
      "scheduleName = ? and activityId = ?",
      [schedule.name, scheduleActivity.activity.activityId],
    );
    notifyListeners();
  }

  updatScheduleActivityByScheduleName(Schedule schedule) {
    DBHelper.update(
      "schedule_activity",
      {
        "activityDone": schedule.scheduleStatus,
      },
      "scheduleName = ?",
      [schedule.name],
    );
    notifyListeners();
  }

  resetActivities(Schedule schedule) async {
    await cancelScheduleNotifications(schedule);

    DBHelper.update(
      "schedule_activity",
      {
        "activityDone": statusNotStarted,
        "startedAt": noValueInDB,
        "endedAt": noValueInDB,
        "editScheduleActivity": 0,
        "editNextActivity": 0,
      },
      "scheduleName = ?",
      [schedule.name],
    );

    notifyListeners();
  }

  removeActivityFromSchedule(
      Schedule schedule, ScheduleActivity scheduleActivity) async {
    //schedules.removeWhere((sc) => sc.name == schedule.name);

    //Cancel Notification
    if (scheduleActivity.notificationId != noValueInDB) {
      await localNotificationService
          .cancelScheduledNotification(scheduleActivity.notificationId);
    }

    DBHelper.removeData(
      "schedule_activity",
      "activityId = ?",
      [scheduleActivity.activity.activityId],
    );

    // DBHelper.removeData(
    //   "activity",
    //   "activityId = ?",
    //   [activity.activityId],
    // );

    schedule.activities.removeWhere((activityArg) =>
        activityArg.activity.activityId ==
        scheduleActivity.activity.activityId);

    updateActivityIndex(schedule);
    notifyListeners();
  }

  removeActivity(Activity activity) {
    DBHelper.removeData(
      "activity",
      "activityId = ?",
      [activity.activityId],
    );
  }

  updateActivity(Activity activity) {
    DBHelper.update(
      "activity",
      {
        "title": activity.title,
        "type": activity.type,
        "lastUpdatedAt": activity.lastUpdatedAt.millisecondsSinceEpoch,
        "editActivity": activity.edit ? 1 : 0,
      },
      "activityId = ?",
      [activity.activityId],
    );
    notifyListeners();
  }

  /* Just for testing */
  clearDataBase() async {
    await DBHelper.removeData('schedule_activity', "", []);
    await DBHelper.removeData('activity', "", []);
    await DBHelper.removeData('schedule', "", []);
    notifyListeners();
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

  //helper function
  updateActivityIndex(Schedule schedule) {
    int dbIndex = 0;
    for (ScheduleActivity scheduleActivity in schedule.activities) {
      DBHelper.update(
        "schedule_activity",
        {
          "activityIndex": dbIndex,
        },
        "scheduleName = ? and activityId = ?",
        [schedule.name, scheduleActivity.activity.activityId],
      );
      dbIndex++;
    }
  }

  //helper function
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

  //helper function
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

  flipDoneActivity(Schedule schedule, ScheduleActivity scheduleActivity) async {
    // activity.activityDone = !activity.activityDone;

    // if (allActivitiesDone(schedule)) {
    //   schedule.scheduleStatus = 1;
    // } else {
    //   schedule.scheduleStatus = 0;
    // }

    // DBHelper.update(
    //   "schedule_activity",
    //   {
    //     "activityDone": activity.activityDone ? 1 : 0,
    //   },
    //   "activityId = ?",
    //   [activity.activityId],
    // );
    // DBHelper.update(
    //   "schedule",
    //   {
    //     "scheduleStatus": schedule.scheduleStatus,
    //   },
    //   "scheduleName = ?",
    //   [schedule.name],
    // );

    scheduleActivity.activityDone = !scheduleActivity.activityDone;

    await updateScheduleActivityByActivityId(
      schedule,
      scheduleActivity,
    );
    if (allActivitiesDone(schedule)) {
      schedule.scheduleStatus = statusDone;
      await updateSchedule(schedule);
    }

    notifyListeners();
  }

  // disposeAds() {
  //   for (int i = 0; i < adIndexInSchedules.length; i++) {
  //     schedules[adIndexInSchedules[i]].dispose();
  //   }
  // }

  DateTime? getDateValueFromDB(int? dateColumnValue) {
    if (dateColumnValue != null && dateColumnValue != -1) {
      return DateTime.fromMillisecondsSinceEpoch(dateColumnValue);
    } else {
      return null;
    }
  }

  Future<List<ScheduleActivity>> loadActivities(Schedule schedule) async {
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
    for (var scheduleActivity in loadedScheduleActivity) {
      ScheduleActivity tempActivity = ScheduleActivity(
        activity: Activity(
          activityId: scheduleActivity['activityId'],
          title: scheduleActivity['title'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(
              scheduleActivity["createdAt"]),
          lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(
              scheduleActivity["lastUpdatedAt"]),
          type: scheduleActivity['type'],
        ),
        activityDone: scheduleActivity['activityDone'] == 1,
        activityDuration:
            Duration(seconds: scheduleActivity['activityDuration']),
        nextActivityAfter:
            Duration(seconds: scheduleActivity['nextActivityAfter']),
      );
      tempActivity.at = getDateValueFromDB(scheduleActivity["startedAt"]);
      tempActivity.endedAt = getDateValueFromDB(scheduleActivity["endedAt"]);
      tempActivity.activity.edit = scheduleActivity['editActivity'] == 1;
      tempActivity.edit = scheduleActivity['editScheduleActivity'] == 1;
      tempActivity.editNextActivity = scheduleActivity['editNextActivity'] == 1;
      schedule.activities.add(tempActivity);
    }
    return schedule.activities;
  }

  fetchSchedules() async {
    List<Map<String, dynamic>> loadedSchedule =
        await DBHelper.getData("schedule", "scheduleIndex DESC");
    schedules = [];
    for (var schedule in loadedSchedule) {
      Schedule tempSchedule = Schedule();
      tempSchedule.name = schedule["scheduleName"];
      tempSchedule.at = getDateValueFromDB(schedule["startedAt"]);
      tempSchedule.endedAt = getDateValueFromDB(schedule["endedAt"]);
      tempSchedule.createdAt = getDateValueFromDB(schedule["createdAt"])!;
      tempSchedule.lastUpdatedAt =
          getDateValueFromDB(schedule["lastUpdatedAt"])!;
      tempSchedule.pinned = schedule["pinned"] == 1;
      tempSchedule.scheduleStatus = schedule["scheduleStatus"];
      //await loadActivities(tempSchedule);
      tempSchedule.edit = schedule["editSchedule"] == 1;
      schedules.add(tempSchedule);
    }

    //Add ads to Schedule
    // adIndexInSchedules = [];
    // for (var i = 1; i < schedules.length + 1; i += 5) {
    //   adIndexInSchedules.add(i);
    //   Schedule adSchedule = Schedule();
    //   adSchedule.name = "Sponsored..$i";
    //   adSchedule.adBanner = BannerAd(
    //     adUnitId: adState.bannerAdUnitId,
    //     size: AdSize.banner,
    //     request: const AdRequest(),
    //     listener: adState.adListener,
    //   )..load();
    //   schedules.insert(i, adSchedule);
    // }
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
        createdAt: DateTime.fromMillisecondsSinceEpoch(activity["createdAt"]),
        lastUpdatedAt:
            DateTime.fromMillisecondsSinceEpoch(activity["lastUpdatedAt"]),
      );
      // tempActivity.activityDuration =
      //     Duration(seconds: activity["activityDuration"] ?? 0);
      // tempActivity.nextActivityAfter =
      //     Duration(seconds: activity["nextActivityAfter"] ?? 0);
      // tempActivity.at = getDateValueFromDB(activity["startedAt"]);
      // tempActivity.endedAt = getDateValueFromDB(activity["endedAt"]);
      tempActivity.edit = activity["editActivity"] == 1;
      activities.insert(0, tempActivity);
    }

    return activities;
  }

  scheduleNotification(
    Schedule schedule,
    DateTime fromDateTime,
    int fromIndex,
  ) async {
    for (int i = fromIndex; i < schedule.activities.length; i++) {
      if (schedule.activities[i].activityDuration.inSeconds == 0) {
        break;
      }

      fromDateTime = fromDateTime.add(schedule.activities[i].activityDuration);
      schedule.activities[i].notificationId =
          await localNotificationService.scheduleNotificationWithActions(
        fromDateTime,
        schedule.name,
        "${schedule.activities[i].activity.title} is completed.",
      );
      await updateScheduleActivityByActivityId(
        schedule,
        schedule.activities[i],
      );
      // if (schedule.activities[i].nextActivityAfter.inSeconds == 0) {
      //   continue;
      // }
      fromDateTime = fromDateTime.add(schedule.activities[i].nextActivityAfter);
      // schedule.activities[i].notificationId = await localNotificationService
      //     .scheduleNotificationWithActions(fromDateTime);
    }
  }

  cancelScheduleNotifications(Schedule schedule) async {
    //Cancel Notifications
    if (schedule.notificationId != noValueInDB) {
      await localNotificationService
          .cancelScheduledNotification(schedule.notificationId);
      schedule.notificationId = noValueInDB;
      await updateSchedule(schedule);
    }
    for (ScheduleActivity scheduleActivity in schedule.activities) {
      if (scheduleActivity.notificationId != noValueInDB) {
        await localNotificationService
            .cancelScheduledNotification(scheduleActivity.notificationId);
        scheduleActivity.notificationId = noValueInDB;
        //await updateScheduleActivityByActivityId(schedule, scheduleActivity);
      }
    }

    await DBHelper.update(
      "schedule_activity",
      {
        "notificationId": noValueInDB,
      },
      "scheduleName = ?",
      [schedule.name],
    );
  }
}
