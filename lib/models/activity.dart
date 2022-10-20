class Activity {
  String title;
  Duration activityDuration; // 0 = No time bound
  Duration nextActivityAfter;

  Activity({
    required this.title,
    required this.activityDuration,
    required this.nextActivityAfter,
  });
}
