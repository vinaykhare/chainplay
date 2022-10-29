import 'package:flutter/material.dart';
import 'package:schedule_it/models/activity.dart';

class Schedule with ChangeNotifier {
  String name = "";
  DateTime at = DateTime.now();
  List<Activity> activities = [];
}
