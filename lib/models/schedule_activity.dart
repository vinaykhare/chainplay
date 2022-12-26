import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/activity.dart';

class ScheduleActivity {
  int notificationId = noValueInDB;

  Duration activityDuration; // 0 = No time bound
  int nextActivityAfter;
  Duration? activityDurationLeft;
  bool activityDone = false, isInterrupted = false;
  DateTime? at, endedAt;
  Activity activity;
  bool edit = false;
  int index = -1;

  ScheduleActivity({
    required this.activity,
    this.activityDuration = const Duration(seconds: 0),
    this.nextActivityAfter = 0,
    this.activityDone = false,
  });
}
