import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';

class AddScheduleScreen extends StatefulWidget {
  static String routename = "/add_schedules";

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  Schedule tempSchedule = Schedule();
  TextEditingController scheduleAtController = TextEditingController();
  DateTime formDateTime = DateTime.now();
  String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> addSchedule() async {
    formKey.currentState?.validate();
    formKey.currentState?.save();
    await Provider.of<ScheduleList>(context, listen: false)
        .addSchedule(tempSchedule);
    Navigator.of(context).pop();
  }

  void getDatePicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    ).then((value) {
      setState(() {
        formDateTime = value ?? DateTime.now();
        scheduleAtController.text =
            DateFormat.yMEd().add_jms().format(formDateTime);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Schedule"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text("Unique Schedule Name"),
                        ),
                        initialValue: tempSchedule.name,
                        onSaved: (newValue) => tempSchedule.name = newValue ??
                            "Schedule ${DateFormat.yMEd().add_jms().format(DateTime.now())}",
                      ),
                      // TextFormField(
                      //   decoration: InputDecoration(
                      //     label: const Text("Schedule At"),
                      //   ),
                      //   controller: scheduleAtController,
                      //   // initialValue:
                      //   //     DateFormat.yMEd().add_jms().format(formDateTime),
                      //   onSaved: (_) {
                      //     tempSchedule.at = formDateTime;
                      //   },
                      //   onTap: getDatePicker,
                      // ),
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text("Number of Repetations"),
                        ),
                        initialValue: tempSchedule.noOfRepeat.toString(),
                        onSaved: (newValue) => tempSchedule.noOfRepeat =
                            int.parse(newValue ?? "1"),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text(
                              "Duration between each repetation (In Seconds)"),
                        ),
                        initialValue:
                            tempSchedule.repeatAfter.inSeconds.toString(),
                        onSaved: (newValue) =>
                            tempSchedule.repeatAfter = Duration(
                          seconds: int.parse(newValue ?? "0"),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          label: const Text(
                              "Duration for each activity (In Seconds)"),
                        ),
                        initialValue:
                            tempSchedule.activityDuration.inSeconds.toString(),
                        onSaved: (newValue) =>
                            tempSchedule.activityDuration = Duration(
                          seconds: int.parse(newValue ?? "0"),
                        ),
                      ),
                      const Divider(),
                      ElevatedButton.icon(
                        onPressed: addSchedule,
                        icon: const Icon(Icons.add_alarm),
                        label: const Text("Add Schedule"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
