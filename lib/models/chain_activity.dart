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
  int index;

  ChainActivity({
    required this.activity,
    this.activityDuration = const Duration(seconds: 0),
    this.repeatType = repeatTypeDoesNotRepeat,
    this.repeatTypeGap = repeatTypeDefaultGap,
    this.repeatCount = repeatTypeDefaultCount,
    this.activityDone = false,
    this.index = -1,
  });

  factory ChainActivity.fromJson(Map<String, dynamic> jsonMap) {
    ChainActivity chainActivity = ChainActivity(
      activityDuration:
          Duration(milliseconds: int.parse(jsonMap['activityDuration'])),
      activity: Activity.fromJson(jsonMap['activity']),
      index: jsonMap['index'],
    );
    //chainActivity.edit = jsonMap['edit'];
    return chainActivity;
  }

  Map<String, dynamic> toJson() {
    return {
      "activityDuration": activityDuration.inMilliseconds.toString(),
      "edit": false,
      "activity": activity,
      "index": index,
    };
  }
}
