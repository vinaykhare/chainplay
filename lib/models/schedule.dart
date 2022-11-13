import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:schedule_it/models/activity.dart';

class Schedule with ChangeNotifier {
  String name = "";
  DateTime? at;
  DateTime lastUpdatedAt = DateTime.now();
  List<Activity> activities = [];
  BannerAd? adBanner;
  bool pinned = false;
}
