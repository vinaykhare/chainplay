import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';

class ChainActivity {
  int startActivityNotificationId = noValueInDB;
  int endActivityNotificationId = noValueInDB;

  Duration activityDuration; // 0 = No time bound
  String repeatType;
  int repeatTypeGap;
  int repeatCount;
  Duration? activityDurationLeft;
  bool activityDone = false, isInterrupted = false;
  DateTime? at, endedAt;
  Activity activity;
  bool edit = false;
  int index = -1;

  ChainActivity({
    required this.activity,
    this.activityDuration = const Duration(seconds: 0),
    this.repeatType = repeatTypeDoesNotRepeat,
    this.repeatTypeGap = repeatTypeDefaultGap,
    this.repeatCount = repeatTypeDefaultCount,
    this.activityDone = false,
  });
}
