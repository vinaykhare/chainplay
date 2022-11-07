import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
//import 'package:schedule_it/screens/add_activity_screen.dart';
import 'package:schedule_it/widgets/activities_timeline.dart';

class AddScheduleScreen extends StatefulWidget {
  static String routename = "/add_schedules";

  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  String pageTitle = "Add Schedule";
  Schedule tempSchedule = Schedule();
  String activityTitle = "";
  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0,
      restDurationAfterHour = 0,
      restDurationAfterMinute = 0,
      restDurationAfterSecond = 0;

  //final TextEditingController scheduleAtController = TextEditingController();
  final TextEditingController addActivityController = TextEditingController();

  DateTime formDateTime = DateTime.now();
  String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> scheduleFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> activityFormKey = GlobalKey<FormState>();

  bool pageInit = true;
  String scheduleNameOnPageLoad = "";

  // void getDatePicker() {
  //   showDatePicker(
  //     context: context,
  //     firstDate: DateTime(2022),
  //     lastDate: DateTime.now(),
  //     initialDate: DateTime.now(),
  //   ).then((value) {
  //     setState(() {
  //       formDateTime = value ?? DateTime.now();
  //       scheduleAtController.text =
  //           DateFormat.yMEd().add_jms().format(formDateTime);
  //     });
  //   });
  // }

  Future<bool> addSchedule() async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);

    bool? valid = scheduleFormKey.currentState?.validate();
    scheduleFormKey.currentState?.save();

    if (valid != null && !valid) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text("Add Activity to Create Schedule!"),
      //   ),
      // );
      return false;
    } else {
      scheduleList.addSchedule(tempSchedule, scheduleNameOnPageLoad);
      //Navigator.of(context).pop();
      return true;
    }
  }

  Future<void> addActivity(Activity newActivity) async {
    setState(
      () {
        tempSchedule.activities.insert(
          0,
          newActivity,
        );
      },
    );
  }

  Future<void> removeActivity(int index) async {
    setState(
      () {
        tempSchedule.activities.removeAt(
          index,
        );
      },
    );
  }

  Future<void> replaceActivity(int index, Activity newActivity) async {
    setState(
      () {
        tempSchedule.activities[index] = newActivity;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempSchedule = ModalRoute.of(context)?.settings.arguments as Schedule;
        pageTitle = "Edit Schedule";
        scheduleNameOnPageLoad = tempSchedule.name;
      }
      pageInit = false;
    }

    final appBarWidget = AppBar(
      centerTitle: true,
      title: Text(pageTitle),
    );

    double appHeight = MediaQuery.of(context).size.height -
        appBarWidget.preferredSize.height -
        MediaQuery.of(context).viewPadding.top;
    return WillPopScope(
      onWillPop: addSchedule,
      child: Scaffold(
        appBar: appBarWidget,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: scheduleFormKey,
            child: SizedBox(
              height: appHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextFormField(
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      label: Text("Unique Schedule Name"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                    initialValue: tempSchedule.name,
                    onSaved: (newValue) => tempSchedule.name = newValue ??
                        "Schedule ${DateFormat.yMEd().add_jms().format(DateTime.now())}",
                    validator: (value) {
                      if (((value == null || value == "") &&
                              tempSchedule.activities.isNotEmpty) ||
                          (value != null &&
                              value != "" &&
                              tempSchedule.activities.isEmpty)) {
                        return "Schdule must have a Unique Name and atleast one Activity.";
                      }
                      // int foundActivityIndex =
                      //     Provider.of<ScheduleList>(context, listen: false)
                      //         .schedules
                      //         .indexWhere((activity) => activity.name == value);
                      // if (foundActivityIndex != -1) {
                      //   return "Unique Name needed.";
                      // }
                      return null;
                    },
                  ),
                  const Divider(
                    thickness: 0,
                    color: Colors.transparent,
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
                  Expanded(
                    child: ActivitiesTimeline(
                      tempSchedule: tempSchedule,
                      removeActivity: removeActivity,
                      replaceActivity: replaceActivity,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            label: Text("Add Activity"),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          controller: addActivityController,
                          onSubmitted: (_) {
                            if (addActivityController.text.isEmpty) {
                              return;
                            }
                            addActivity(
                              Activity(title: addActivityController.text),
                            );
                            addActivityController.clear();
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (addActivityController.text.isEmpty) {
                            return;
                          }
                          addActivity(
                            Activity(title: addActivityController.text),
                          );
                          addActivityController.clear();
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        // floatingActionButton: ElevatedButton.icon(
        //   onPressed: () async {
        //     Activity tempAcitivity = await Navigator.of(context)
        //         .pushNamed(AddActivityScreen.routename) as Activity;
        //     addActivity(tempAcitivity);
        //   },
        //   label: const Text("Add Activity"),
        //   icon: const Icon(
        //     Icons.add_task_rounded,
        //   ),
        // ),
      ),
    );
  }
}
