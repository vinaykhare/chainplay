import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule_it/models/activity.dart';

class Schedule with ChangeNotifier {
  DateTime at = DateTime.now();
  String name =
      "Schedule ${DateFormat.yMEd().add_jms().format(DateTime.now())}";
  int noOfRepeat = 1;
  Duration repeatAfter = Duration(seconds: 1);
  Duration activityDuration = Duration(seconds: 1);

  List<Activity> activities = [];
}
