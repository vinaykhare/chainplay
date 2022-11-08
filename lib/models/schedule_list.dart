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

  addSchedule(Schedule schedule, String oldScheduleName) async {
    int index =
        schedules.indexWhere((element) => element.name == schedule.name);

    if (index == -1) {
      schedules.add(schedule);
    } else {
      //schedules[index] = schedule;
      removeSchedule(oldScheduleName);
    }

    //maxScheduleIndex = (await DBHelper.getMax("Activity", "scheduleIndex")) as int;

    for (var activity in schedule.activities) {
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
          "activityDone": activity.activityDone ? 1 : 0,
          "scheduleName": schedule.name,
          "lastUpdatedAt": schedule.lastUpdatedAt.millisecondsSinceEpoch,
          "pinned": schedule.pinned ? 1 : 0,
        },
      );
      //activity.syncedWithDb = true;
    }
    notifyListeners();
  }

  removeSchedule(String scheduleName) {
    //schedules.removeWhere((sc) => sc.name == schedule.name);

    DBHelper.removeData("activity", "scheduleName = ?", [scheduleName]);

    notifyListeners();
  }

  rearrangeSchedules(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var itemAtOldIndex = schedules.removeAt(oldIndex);
    schedules.insert(newIndex, itemAtOldIndex);

    //Reschedule in DB here.
    DBHelper.removeData("activity", "", []);
    for (Schedule schedule in schedules) {
      if (schedule.adBanner == null) {
        addSchedule(schedule, "");
      }
    }
    notifyListeners();
  }

  pinSchedule(schedule) {
    schedule.pinned = !schedule.pinned;
    DBHelper.update(
      "activity",
      {
        "pinned": schedule.pinned ? 1 : 0,
      },
      "scheduleName = ?",
      [schedule.name],
    );
    notifyListeners();
  }

  getScheduleByName(String scheduleName) {
    return schedules.firstWhere((element) => scheduleName == element.name,
        orElse: () => Schedule());
  }

  disposeAds() {
    for (int i = 0; i < adIndexInSchedules.length; i++) {
      schedules[adIndexInSchedules[i]].dispose();
    }
  }

  fetchAllSchedules() async {
    List<Map<String, dynamic>> loadedActivities =
        await DBHelper.getData("activity");
    Map<String, List<Activity>> mappedActivities = {};
    Map<String, Map<String, int>> scheduleParameters = {};
    for (var activity in loadedActivities) {
      if (mappedActivities[activity["scheduleName"]] == null) {
        mappedActivities[activity["scheduleName"]] = [];
      }
      mappedActivities[activity["scheduleName"]]!.add(
        Activity(
          title: activity["title"],
          activityDuration: Duration(seconds: activity["activityDuration"]),
          nextActivityAfter: Duration(seconds: activity["nextActivityAfter"]),
          activityDone: activity["activityDone"] == 1,
        ),
      );

      scheduleParameters[activity["scheduleName"]] = {
        "lastUpdatedAt": activity["lastUpdatedAt"],
        "pinned": activity["pinned"],
      };
    }

    schedules = mappedActivities.entries.map(
      (entry) {
        Schedule schedule = Schedule();
        schedule.name = entry.key;
        schedule.activities = entry.value;
        schedule.lastUpdatedAt = DateTime.fromMillisecondsSinceEpoch(
            scheduleParameters[schedule.name]!["lastUpdatedAt"] as int);
        schedule.pinned = scheduleParameters[schedule.name]!["pinned"] == 1;
        return schedule;
      },
    ).toList();

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
}
