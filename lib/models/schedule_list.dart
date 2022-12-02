import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/constants.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:schedule_it/helpers/ad_state.dart';
import 'package:schedule_it/helpers/db_helper.dart';
import 'package:schedule_it/helpers/notification_helper.dart';

import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/system_setting.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
//import 'package:schedule_it/screens/play_schedule_screen.dart';

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
  bool loaded = false;
  List<Schedule> schedules = [];
  List<Activity> activities = [];
  List<SystemSetting> systemSettings = [];
  NotificationHelper notificationHelper = NotificationHelper();
  Schedule? notificationCameForSchedule;
  String? notificaitonCameForUrl;
  //List<int> adIndexInSchedules = [];
  //final AdState adState;
  final BuildContext context;

  ScheduleList(
    this.context,
    //this.notificationHelper,
    //this.adState,
  );

  Future<void> initialize() async {
    await fetchSchedules();
    await fetchActivities();
    await fetchSettings();
    await notificationHelper.initialize(systemSettings);

    if (notificationHelper.notificationCameForScheduleName != "" &&
        notificationHelper.notificationCameForScheduleName != null) {
      int indexOfScheduleNotified = schedules.indexWhere((sch) =>
          sch.name == notificationHelper.notificationCameForScheduleName);
      notificationCameForSchedule = indexOfScheduleNotified == -1
          ? null
          : schedules[indexOfScheduleNotified];
      notificaitonCameForUrl = notificationHelper.notificaitonCameForUrl;
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> addSchedule(
      Schedule schedule, ScheduleActivity scheduleActivity) async {
    int scheduleIndex =
        schedules.indexWhere((sch) => sch.name == schedule.name);

    if (scheduleIndex == -1) {
      schedules.add(schedule);
    } else {
      schedules[scheduleIndex] = schedule;
    }

    int activityIndex = activities
        .indexWhere((act) => act.title == scheduleActivity.activity.title);

    if (activityIndex == -1) {
      activities.add(scheduleActivity.activity);
    } else {
      scheduleActivity.activity = activities[activityIndex];
    }

    int scheduleActivityIndex =
        schedule.activities.isEmpty ? 0 : schedule.activities.length - 1;

    if (activityIndex == -1) {
      await DBHelper.insert(
        "activity",
        {
          "activityId": scheduleActivity.activity.activityId,
          "title": scheduleActivity.activity.title,
          "type": scheduleActivity.activity.type,
          "createdAt":
              scheduleActivity.activity.createdAt.millisecondsSinceEpoch,
          "lastUpdatedAt":
              scheduleActivity.activity.lastUpdatedAt.millisecondsSinceEpoch,
          "editActivity": scheduleActivity.activity.edit ? 1 : 0,
        },
      );
    }
    if (scheduleIndex == -1) {
      await DBHelper.insert(
        "schedule",
        {
          "scheduleName": schedule.name,
          "scheduleIndex": schedules.length,
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
          "notificationId": schedule.notificationId.toString(),
          "editSchedule": 1,
        },
      );
    }
    await DBHelper.insert(
      "schedule_activity",
      {
        "scheduleName": schedule.name,
        "activityId": scheduleActivity.activity.activityId,
        "activityIndex": scheduleActivityIndex,
        "activityDone": scheduleActivity.activityDone ? 1 : 0,
        "notificationId": scheduleActivity.notificationId.toString(),
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

  Future<void> removeSchedule(Schedule schedule) async {
    schedules.removeWhere((sch) => sch.name == schedule.name);
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

  Future<void> renameSchedule(
      String oldScheduleName, String newScheduleName) async {
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

  Future<void> updateSchedule(Schedule schedule) async {
    int scheduleIndex =
        schedules.indexWhere((sch) => sch.name == schedule.name);
    schedules[scheduleIndex] = schedule;
    await DBHelper.update(
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
        "notificationId": schedule.notificationId.toString(),
        "editSchedule": schedule.edit ? 1 : 0,
      },
      "scheduleName = ?",
      [schedule.name],
    );
    notifyListeners();
  }

  Future<void> updateScheduleActivityByActivityId(
      Schedule schedule, ScheduleActivity scheduleActivity) async {
    await DBHelper.update(
      "schedule_activity",
      {
        "activityDone": scheduleActivity.activityDone,
        "notificationId": scheduleActivity.notificationId.toString(),
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

  Future<void> updatScheduleActivityByScheduleName(
    Schedule schedule, [
    bool editScheduleActivity = false,
    bool editNextActivity = false,
  ]) async {
    await DBHelper.update(
      "schedule_activity",
      {
        "activityDone": schedule.scheduleStatus,
        "editScheduleActivity": editScheduleActivity,
        "editNextActivity": editNextActivity,
      },
      "scheduleName = ?",
      [schedule.name],
    );
    notifyListeners();
  }

  Future<void> resetActivities(Schedule schedule) async {
    await cancelScheduleNotifications(schedule);

    for (ScheduleActivity activity in schedule.activities) {
      activity.edit = false;
      activity.editNextActivity = false;
      activity.activityDone = false;
      activity.at = null;
      activity.endedAt = null;
    }

    await DBHelper.update(
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

  Future<void> removeActivityFromSchedule(
      Schedule schedule, ScheduleActivity scheduleActivity) async {
    //schedules.removeWhere((sc) => sc.name == schedule.name);

    //Cancel Notification
    if (scheduleActivity.notificationId != noValueInDB) {
      await notificationHelper
          .cancelNotificationById(scheduleActivity.notificationId);
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

  Future<void> removeActivity(Activity activity) async {
    DBHelper.removeData(
      "activity",
      "activityId = ?",
      [activity.activityId],
    );
  }

  Future<void> updateActivity(Activity activity) async {
    await DBHelper.update(
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
  Future<void> clearDataBase() async {
    await DBHelper.removeData('schedule_activity', "", []);
    await DBHelper.removeData('activity', "", []);
    await DBHelper.removeData('schedule', "", []);
    schedules = [];
    activities = [];
    notifyListeners();
  }

  Future<void> rearrangeSchedules(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var itemAtOldIndex = schedules.removeAt(oldIndex);
    schedules.insert(newIndex, itemAtOldIndex);

    await updateScheduleIndex();
    notifyListeners();
  }

  Future<void> rearrangeActivites(
      Schedule schedule, int oldIndex, int newIndex) async {
    // if (oldIndex == newIndex) {
    //   return;
    // }

    if (oldIndex > newIndex) {
      newIndex += 1;
    }

    var itemAtOldIndex = schedule.activities.removeAt(oldIndex);
    schedule.activities.insert(newIndex, itemAtOldIndex);
    await updateActivityIndex(schedule);
    notifyListeners();
  }

  //helper function
  Future<void> updateActivityIndex(Schedule schedule) async {
    int dbIndex = 0;
    for (ScheduleActivity scheduleActivity in schedule.activities) {
      await DBHelper.update(
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
  Future<void> updateScheduleIndex() async {
    int dbIndex = 0;
    for (Schedule schedule in schedules) {
      if (schedule.adBanner != null) {
        continue;
      }
      await DBHelper.update(
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

  Future<void> flipDoneActivity(
      Schedule schedule, ScheduleActivity scheduleActivity) async {
    // activity.activityDone = !activity.activityDone;

    // if (allActivitiesDone(schedule)) {
    //   schedule.scheduleStatus = 1;
    // } else {
    //   schedule.scheduleStatus = 0;
    // }

    // await DBHelper.update(
    //   "schedule_activity",
    //   {
    //     "activityDone": activity.activityDone ? 1 : 0,
    //   },
    //   "activityId = ?",
    //   [activity.activityId],
    // );
    // await DBHelper.update(
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

  Future<void> playNotificationSound() async {
    await notificationHelper.playNotificationSound();
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

  Future<void> setSetting(String key, String value) async {
    int keyIndex = systemSettings.indexWhere((set) => set.key == key);
    systemSettings[keyIndex].value = value;
    await DBHelper.update(
      'settings',
      {
        'value': value,
      },
      'key = ?',
      [key],
    );
    notificationHelper.systemSetting = systemSettings;
    notifyListeners();
  }

  Future<List<SystemSetting>> fetchSettings() async {
    List<Map<String, dynamic>> loadedSettings =
        await DBHelper.getData("settings", "type ASC");
    systemSettings = [];
    for (var loadedSetting in loadedSettings) {
      SystemSetting setting = SystemSetting();
      setting.key = loadedSetting["key"];
      setting.value = loadedSetting["value"];
      setting.type = loadedSetting["type"];
      systemSettings.add(setting);
    }

    return systemSettings;
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
      tempActivity.notificationId =
          int.parse(scheduleActivity['notificationId']);
      schedule.activities.add(tempActivity);
    }
    return schedule.activities;
  }

  Future<List<Schedule>> fetchSchedules() async {
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
      tempSchedule.activities = await loadActivities(tempSchedule);
      tempSchedule.edit = schedule["editSchedule"] == 1;
      tempSchedule.notificationId = int.parse(schedule["notificationId"]);
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

  Future<List<Activity>> fetchActivities() async {
    List<Map<String, dynamic>> loadedActivities =
        await DBHelper.getData("activity", "activityId");

    activities = [];

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

  Future<void> scheduleNotification(
    Schedule schedule,
    DateTime fromDateTime,
    int fromIndex,
  ) async {
    for (int i = fromIndex; i < schedule.activities.length; i++) {
      if (schedule.activities[i].activityDuration.inSeconds == 0) {
        schedule.activities[i].notificationId =
            await notificationHelper.scheduleNotification(
          DateTime.now().add(const Duration(seconds: 1)),
          schedule.name,
          "${schedule.activities[i].activity.title} has Started.",
          {
            "scheduleName": schedule.name,
            "url": PlaySchedule.routename,
          },
        );
        await updateScheduleActivityByActivityId(
          schedule,
          schedule.activities[i],
        );
        break;
      }

      fromDateTime = fromDateTime.add(schedule.activities[i].activityDuration);
      schedule.activities[i].notificationId =
          await notificationHelper.scheduleNotification(
        fromDateTime,
        schedule.name,
        "${schedule.activities[i].activity.title} is completed.",
        {
          "scheduleName": schedule.name,
          "url": PlaySchedule.routename,
        },
      );
      await updateScheduleActivityByActivityId(
        schedule,
        schedule.activities[i],
      );
      // if (schedule.activities[i].nextActivityAfter.inSeconds == 0) {
      //   continue;
      // }
      fromDateTime = fromDateTime.add(schedule.activities[i].nextActivityAfter);
      // schedule.activities[i].notificationId = await notificationHelper
      //     .scheduleNotificationWithActions(fromDateTime);
    }
    notifyListeners();
  }

  Future<void> cancelScheduleNotifications(Schedule schedule) async {
    //Cancel Notifications
    if (schedule.notificationId != noValueInDB) {
      await notificationHelper.cancelNotificationById(schedule.notificationId);
      schedule.notificationId = noValueInDB;
      await updateSchedule(schedule);
    }
    for (ScheduleActivity scheduleActivity in schedule.activities) {
      if (scheduleActivity.notificationId != noValueInDB) {
        await notificationHelper
            .cancelNotificationById(scheduleActivity.notificationId);
        scheduleActivity.notificationId = noValueInDB;
        //await updateScheduleActivityByActivityId(schedule, scheduleActivity);
      }
    }

    await DBHelper.update(
      "schedule_activity",
      {
        "notificationId": noValueInDB.toString(),
      },
      "scheduleName = ?",
      [schedule.name],
    );
    notifyListeners();
  }
}
