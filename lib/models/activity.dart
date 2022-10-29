import 'package:uuid/uuid.dart';

class Activity {
  String activityId = const Uuid().v1();
  String title;
  Duration activityDuration; // 0 = No time bound
  Duration nextActivityAfter;

  Activity({
    required this.title,
    required this.activityDuration,
    required this.nextActivityAfter,
  });
}
