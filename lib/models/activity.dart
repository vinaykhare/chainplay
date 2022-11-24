import 'package:schedule_it/helpers/constants.dart';

class Activity {
  String activityId;
  String title;
  int type;
  DateTime createdAt, lastUpdatedAt;
  bool edit = false;

  Activity({
    required this.activityId,
    required this.title,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.type = taskActivityInDB,
  });
}
