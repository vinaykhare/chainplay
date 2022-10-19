import 'package:flutter/material.dart';
import 'package:schedule_it/models/schedule.dart';

class ScheduleList with ChangeNotifier {
  List<Schedule> schedules = [];

  addSchedule(Schedule schedule) {
    schedules.add(schedule);
    notifyListeners();
  }

  removeSchedule(Schedule schedule) {
    schedules.removeWhere((sc) => sc.name == schedule.name);
    notifyListeners();
  }

  getScheduleByName(String scheduleName) {
    return schedules.firstWhere((element) => scheduleName == element.name);
  }
}
