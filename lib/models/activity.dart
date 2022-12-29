import 'package:chain_activities/helpers/constants.dart';

class Activity {
  String activityId;
  String title;
  int type;
  DateTime createdAt, lastUpdatedAt;
  bool edit = false;
  Map<String, dynamic>? specification = {};

  Activity({
    required this.activityId,
    required this.title,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.type = waitActivityInDB,
    this.specification,
  });
}
