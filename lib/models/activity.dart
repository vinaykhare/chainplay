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

  factory Activity.fromJson(Map<String, dynamic> jsonMap) {
    Activity activity = Activity(
      title: jsonMap['title'],
      activityId: jsonMap['activityId'],
      type: jsonMap['type'],
      createdAt: DateTime.parse(jsonMap['createdAt']),
      lastUpdatedAt: DateTime.parse(jsonMap['lastUpdatedAt']),
      specification: jsonMap['specification'] as Map<String, dynamic>?,
    );
    //activity.edit = jsonMap['edit'];
    return activity;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? specificationWithoutLocalRef = specification != null
        ? Map<String, dynamic>.from(specification!)
        : null;
    if (specificationWithoutLocalRef != null &&
        specificationWithoutLocalRef[activitySpecImagePath]
            .toString()
            .startsWith("/data")) {
      specificationWithoutLocalRef[activitySpecImagePath] = "";
    }
    return {
      "title": title,
      "activityId": activityId,
      "type": type,
      "createdAt": createdAt.toIso8601String(),
      "lastUpdatedAt": lastUpdatedAt.toIso8601String(),
      "specification": specificationWithoutLocalRef,
    };
  }
}
