import 'package:flutter/material.dart';
import 'package:schedule_it/models/schedule.dart';

class ScheduleScreen extends StatelessWidget {
  static String routename = "/schedule";

  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Schedule schedule = ModalRoute.of(context)?.settings.arguments as Schedule;
    AppBar appBarWidget = AppBar(
      centerTitle: true,
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
              const Text("Start"),
              SizedBox(
                height: appHeight,
                child: const Text("Deprecated"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
