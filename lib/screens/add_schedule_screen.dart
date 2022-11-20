import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
//import 'package:schedule_it/screens/add_activity_screen.dart';
import 'package:schedule_it/widgets/activities_timeline.dart';
import 'package:uuid/uuid.dart';

class AddScheduleScreen extends StatefulWidget {
  static String routename = "/add_schedules";

  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  FocusNode addActivityFocus = FocusNode();
  String pageTitle = "Add Schedule";
  Schedule tempSchedule = Schedule();
  String activityTitle = "", errorString = "";
  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0,
      restDurationAfterHour = 0,
      restDurationAfterMinute = 0,
      restDurationAfterSecond = 0;

  final TextEditingController addActivityController = TextEditingController();

  DateTime formDateTime = DateTime.now();
  //String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> scheduleFormKey = GlobalKey<FormState>();

  bool pageInit = true;
  String scheduleNameOnPageLoad = "";

  @override
  void dispose() {
    super.dispose();
    addActivityFocus.dispose();
    addActivityController.dispose();
  }

  Future<bool> validateForm() async {
    bool valid = scheduleFormKey.currentState!.validate();
    if (!valid) {
      return false;
    }
    scheduleFormKey.currentState?.save();

    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);

    if (tempSchedule.activities.isNotEmpty && tempSchedule.name == "") {
      setState(() {
        errorString =
            "Give a valid name to this Schedule!\n OR\n Remove all Activites to delete the Schedule.";
      });
      return false;
    }

    if (tempSchedule.activities.isEmpty && tempSchedule.name != "") {
      setState(() {
        errorString = "Add atleast one activity to this Schedule.";
      });
      return false;
    }

    //tempSchedule.name = pageTitle;

    if (tempSchedule.activities.isEmpty && tempSchedule.name == "") {
      tempSchedule.name = scheduleNameOnPageLoad;
      scheduleList.removeSchedule(tempSchedule);
    } else if (tempSchedule.activities.isNotEmpty &&
        tempSchedule.name != scheduleNameOnPageLoad) {
      scheduleList.renameSchedule(
        scheduleNameOnPageLoad,
        tempSchedule.name,
      );
    }

    return true;
  }

  Future<void> addActivity(ScheduleActivity newActivity) async {
    tempSchedule.activities.insert(
      0,
      newActivity,
    );
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);

    scheduleList.addSchedule(tempSchedule, newActivity);
    //Navigator.of(context).pop();
    setState(() {});
  }

  void onSubmitText() {
    setState(() {
      errorString = "";
    });
    bool valid = scheduleFormKey.currentState!.validate();
    if (!valid) {
      return;
    }
    scheduleFormKey.currentState?.save();
    if (tempSchedule.name == "") {
      setState(() {
        errorString =
            "Please insert the Schedule name before adding activity to it.";
      });
      return;
    }
    if (addActivityController.text.isEmpty) {
      return;
    }
    addActivity(
      ScheduleActivity(
        activity: Activity(
          title: addActivityController.text,
          createdAt: DateTime.now(),
          lastUpdatedAt: DateTime.now(),
          activityId: const Uuid().v1(),
        ),
      ),
    );

    addActivityController.clear();

    FocusScope.of(context).requestFocus(addActivityFocus);
  }

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempSchedule = ModalRoute.of(context)?.settings.arguments as Schedule;
        pageTitle = tempSchedule.name;
        scheduleNameOnPageLoad = tempSchedule.name;
        //tempSchedule.loadActivities();
      }
      pageInit = false;
      //FocusScope.of(context).requestFocus(addActivityFocus);
    }

    final appBarWidget = AppBar(
      centerTitle: true,
      title: Form(
        key: scheduleFormKey,
        child: TextFormField(
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.only(
              bottom: 20,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            label: Text("Unique Schedule Name"),
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.all(
            //     Radius.circular(20),
            //   ),
            // ),
          ),
          initialValue: tempSchedule.name,
          validator: (value) {
            if ((value == null || value == "") &&
                tempSchedule.activities.isNotEmpty) {
              return "Inesrt valid Schedule Name";
            }
            return null;
          },
          onSaved: (value) {
            tempSchedule.name = value ?? "";
          },
        ),
      ),
      actions: const [],
    );

    double appHeight = MediaQuery.of(context).size.height -
        appBarWidget.preferredSize.height -
        MediaQuery.of(context).viewPadding.top;

    return WillPopScope(
      onWillPop: validateForm,
      child: Scaffold(
        appBar: appBarWidget,
        body: SizedBox(
          height: appHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: TextFormField(
              //     textAlign: TextAlign.center,
              //     //enabled: tempSchedule.activities.isEmpty,
              //     style: Theme.of(context).textTheme.headline4,
              //     decoration: const InputDecoration(
              //       contentPadding: EdgeInsets.all(10),
              //       floatingLabelBehavior: FloatingLabelBehavior.never,
              //       label: Text("Unique Schedule Name"),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.all(
              //           Radius.circular(20),
              //         ),
              //       ),
              //     ),
              //     initialValue: tempSchedule.name,
              //     onSaved: (newValue) => tempSchedule.name = newValue ??
              //         "Schedule ${DateFormat.yMEd().add_jms().format(DateTime.now())}",
              //     validator: (value) {
              //       if (tempSchedule.activities.isNotEmpty) {
              //         if (value == null || value == "") {
              //           return "Schedule must have a name.";
              //         }
              //       } else {
              //         if (value != null && value != "") {
              //           return "Add one or more activities to this Schedule.";
              //         }
              //       }
              //       // int foundActivityIndex =
              //       //     Provider.of<ScheduleList>(context, listen: false)
              //       //         .schedules
              //       //         .indexWhere((activity) => activity.name == value);
              //       // if (foundActivityIndex != -1) {
              //       //   return "Unique Name needed.";
              //       // }
              //       return null;
              //     },
              //     onFieldSubmitted: (value) =>
              //         FocusScope.of(context).requestFocus(addActivityFocus),
              //   ),
              // ),
              if (errorString != "")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorString,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              const Divider(
                thickness: 0,
                color: Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ActivitiesTimeline(
                    tempSchedule: tempSchedule,
                  ),
                ),
              ),
              AppBar(
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        cursorColor: Theme.of(context).shadowColor,
                        focusNode: addActivityFocus,
                        decoration: const InputDecoration(
                          label: Text(
                            'Add Task or Activity',
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: addActivityController,
                        onSubmitted: (_) {
                          onSubmitText();
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        onSubmitText();
                      },
                      icon: const Icon(Icons.add_task),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
