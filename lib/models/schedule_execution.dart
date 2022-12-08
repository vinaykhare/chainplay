import 'package:flutter/material.dart';
import 'package:schedule_it/helpers/constants.dart';

class ScheduleExecution with ChangeNotifier {
  String scheduleExecutionId = "";
  String scheduleName = "";
  DateTime? startedAt, pausedAt, endedAt;
  int scheduleStatus = statusNotStarted;
  int notificationId = noValueInDB;
}
