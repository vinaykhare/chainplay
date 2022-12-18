//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_execution.dart';

class Schedule {
  String name = "";
  DateTime? at, endedAt;
  DateTime lastUpdatedAt = DateTime.now();
  DateTime createdAt = DateTime.now();
  List<ScheduleActivity> activities = [];
  List<ScheduleExecution> scheduleHistory = [];
  //BannerAd? adBanner;
  bool pinned = false;
  int scheduleStatus = statusNotStarted;
  int notificationId = noValueInDB;
  bool edit = false;
  int index = -1;
}
