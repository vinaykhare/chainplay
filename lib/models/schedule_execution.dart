import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/schedule_activity.dart';

class ScheduleExecution {
  String scheduleExecutionId = "";
  String scheduleName = "";
  DateTime? startedAt, endedAt;
  int scheduleStatus = statusNotStarted;
  int notificationId = noValueInDB;
  List<ScheduleActivity> scheduleActivities = [];
}
