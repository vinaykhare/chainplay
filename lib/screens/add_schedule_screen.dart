import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
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
  String activityTitle = "";
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
    bool? valid = scheduleFormKey.currentState?.validate();
    scheduleFormKey.currentState?.save();

    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    if (valid != null && valid) {
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
    }
    return valid ?? true;
  }

  Future<void> addActivity(Activity newActivity) async {
    tempSchedule.activities.insert(
      0,
      newActivity,
    );
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);

    bool? valid = scheduleFormKey.currentState?.validate();
    scheduleFormKey.currentState?.save();

    if (valid != null && valid) {
      scheduleList.addSchedule(tempSchedule, newActivity);
      //Navigator.of(context).pop();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempSchedule = ModalRoute.of(context)?.settings.arguments as Schedule;
        pageTitle = "Manage Schedule";
        scheduleNameOnPageLoad = tempSchedule.name;
        //tempSchedule.loadActivities();
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
      onWillPop: validateForm,
      child: Scaffold(
        appBar: appBarWidget,
        body: Form(
          key: scheduleFormKey,
          child: SizedBox(
            height: appHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    //enabled: tempSchedule.activities.isEmpty,
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
                      if (tempSchedule.activities.isNotEmpty) {
                        if (value == null || value == "") {
                          return "Schedule must have a name.";
                        }
                      } else {
                        if (value != null && value != "") {
                          return "Add one or more activities to this Schedule.";
                        }
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
                    onFieldSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(addActivityFocus),
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
                          cursorColor: Theme.of(context).cardColor,
                          focusNode: addActivityFocus,
                          decoration: InputDecoration(
                            label: Text(tempSchedule.activities.isEmpty
                                ? 'Insert Schedule Name'
                                : 'Add One Liner Task or Activity'),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          controller: addActivityController,
                          onSubmitted: (_) {
                            if (addActivityController.text.isEmpty) {
                              return;
                            }
                            addActivity(
                              Activity(
                                  title: addActivityController.text,
                                  activityId: const Uuid().v1()),
                            );
                            addActivityController.clear();

                            FocusScope.of(context)
                                .requestFocus(addActivityFocus);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (addActivityController.text.isEmpty) {
                            return;
                          }
                          addActivity(
                            Activity(
                                title: addActivityController.text,
                                activityId: const Uuid().v1()),
                          );
                          addActivityController.clear();
                          FocusScope.of(context).requestFocus(addActivityFocus);
                        },
                        icon: const Icon(Icons.add_task),
                      ),
                    ],
                  ),
                )
              ],
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
