import 'package:uuid/uuid.dart';

class Activity {
  String activityId = const Uuid().v1();
  String title;
  Duration activityDuration; // 0 = No time bound
  Duration nextActivityAfter;

  Activity({
    required this.title,
    this.activityDuration = const Duration(seconds: 0),
    this.nextActivityAfter = const Duration(seconds: 0),
  });
}
