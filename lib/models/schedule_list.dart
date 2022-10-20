import 'package:flutter/material.dart';
import 'package:schedule_it/models/schedule.dart';

class ScheduleList with ChangeNotifier {
  List<Schedule> schedules = [];

  addSchedule(Schedule schedule) {
    int index =
        schedules.indexWhere((element) => element.name == schedule.name);

    if (index == -1) {
      schedules.add(schedule);
    } else {
      schedules[index] = schedule;
    }
    notifyListeners();
  }

  removeSchedule(Schedule schedule) {
    schedules.removeWhere((sc) => sc.name == schedule.name);
    notifyListeners();
  }

  getScheduleByName(String scheduleName) {
    return schedules.firstWhere((element) => scheduleName == element.name,
        orElse: () => Schedule());
  }
}
