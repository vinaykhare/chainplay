import 'package:flutter/material.dart';
import 'package:schedule_it/models/schedule.dart';

class ScheduleScreen extends StatelessWidget {
  static String routename = "/schedule";

  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Schedule schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
    AppBar appBarWidget = AppBar(
      title: Text(schedule.name),
    );
    double appHeight = MediaQuery.of(context).size.height -
        appBarWidget.preferredSize.height -
        MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      appBar: appBarWidget,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Text("Activities"),
              SizedBox(
                height: appHeight,
                child: ListView.builder(
                  itemCount: schedule.activities.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          width: 5,
                          height: appHeight * 0.05,
                          decoration: const BoxDecoration(color: Colors.amber),
                        ),
                        Card(
                          elevation: 10,
                          child: ListTile(
                            title: Text(schedule.activities[index].title),
                            trailing: Text(
                              "for ${schedule.activities[index].activityDuration.inSeconds} Seconds.",
                            ),
                          ),
                        ),
                        Container(
                          width: 5,
                          height: appHeight * 0.05,
                          decoration: const BoxDecoration(color: Colors.amber),
                        ),
                        Text(
                          schedule.activities[index].nextActivityAfter
                                      .inSeconds ==
                                  0
                              ? "No Rest"
                              : "Rest for ${schedule.activities[index].nextActivityAfter.inSeconds} Seconds.",
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
