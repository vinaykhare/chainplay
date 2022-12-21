import 'package:flutter/material.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/widgets/schedule_activities.dart';

class ScheduleActivitiesHistoryScreen extends StatelessWidget {
  static String routename = "/schedule_activities_history";
  const ScheduleActivitiesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;

    Schedule scheduleExecution =
        ModalRoute.of(context)?.settings.arguments as Schedule;
    // Schedule tempScheudule = Schedule();
    // tempScheudule.name = scheduleExecution.name;
    // tempScheudule.at = scheduleExecution.at;
    // tempScheudule.endedAt = scheduleExecution.endedAt;
    // tempScheudule.activities = scheduleExecution.scheduleActivities;
    // tempScheudule.scheduleStatus = scheduleExecution.scheduleStatus;
    // tempScheudule.notificationId = scheduleExecution.notificationId;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            // margin: const EdgeInsets.only(top: 50),
            // padding: const EdgeInsets.all(10),
            height: appHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScheduleActivities(
                      tempSchedule: scheduleExecution,
                      editActivity: null,
                      undoEdit: null,
                    ),
                  ),
                ),
                AppBar(
                  title: TextFormField(
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    initialValue: scheduleExecution.name,
                    enabled: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
