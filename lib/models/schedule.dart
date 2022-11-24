import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/schedule_activity.dart';

class Schedule with ChangeNotifier {
  String name = "";
  DateTime? at, endedAt;
  DateTime lastUpdatedAt = DateTime.now();
  DateTime createdAt = DateTime.now();
  List<ScheduleActivity> activities = [];
  BannerAd? adBanner;
  bool pinned = false;
  int scheduleStatus = statusNotStarted;
  int notificationId = noValueInDB;
  bool edit = false;
}
