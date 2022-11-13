class Activity {
  String activityId;
  String title;
  Duration activityDuration; // 0 = No time bound
  Duration nextActivityAfter;
  bool activityDone = false;

  Activity({
    required this.activityId,
    required this.title,
    this.activityDuration = const Duration(seconds: 0),
    this.nextActivityAfter = const Duration(seconds: 0),
    this.activityDone = false,
  });
}
