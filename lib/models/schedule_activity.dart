import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/activity.dart';

class ScheduleActivity {
  int notificationId = noValueInDB;

  Duration activityDuration; // 0 = No time bound
  Duration nextActivityAfter;
  bool activityDone = false;
  DateTime? at, endedAt;
  Activity activity;
  bool edit = false, editNextActivity = false;

  ScheduleActivity({
    required this.activity,
    this.activityDuration = const Duration(seconds: 0),
    this.nextActivityAfter = const Duration(seconds: 0),
    this.activityDone = false,
  });
}
