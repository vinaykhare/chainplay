import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/helpers/db_helper.dart';

class Schedule with ChangeNotifier {
  String name = "";
  DateTime? at;
  DateTime lastUpdatedAt = DateTime.now();
  List<Activity> activities = [];
  BannerAd? adBanner;
  bool pinned = false;

  loadActivities() async {
    List<Map<String, dynamic>> loadedScheduleActivity =
        await DBHelper.getDataBySQL(
      '''
      SELECT schedule_activity.scheduleName, activity.*
      FROM schedule_activity
      JOIN activity ON (schedule_activity.activityId = activity.activityId)
      WHERE schedule_activity.scheduleName = ?
      ORDER BY schedule_activity.activityIndex 
      ''',
      [name],
    );

    for (var activity in loadedScheduleActivity) {
      Activity tempActivity = Activity(
        title: activity['title'],
        activityDone: activity['activityDone'] == 1,
        activityDuration: Duration(seconds: activity['activityDuration']),
        nextActivityAfter: Duration(seconds: activity['nextActivityAfter']),
      );
      tempActivity.activityId = activity['activityId'];
      activities.add(tempActivity);
    }
    notifyListeners();
  }
}
