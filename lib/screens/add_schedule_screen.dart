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
  ScheduleActivity? scheduleActivityInEditMode;
  String activityTitle = "", errorString = "";
  bool addingDurationToActivity = false,
      updatingNextActivityAfterDuration = false,
      continueAddingHere = false;
  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0;

  final TextEditingController addActivityController = TextEditingController();

  DateTime formDateTime = DateTime.now();
  //String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> scheduleFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> durationFormKey = GlobalKey<FormState>();

  bool pageInit = true;
  String scheduleNameOnPageLoad = "";

  @override
  void dispose() {
    super.dispose();
    addActivityFocus.dispose();
    addActivityController.dispose();
  }

  Future<bool> isNameValid() async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    bool nameExist = await scheduleList.nameExistInDB(tempSchedule.name);
    if (nameExist && !continueAddingHere) {
      setState(() {
        errorString =
            "Schedule name ${tempSchedule.name} is already present with following activities";
      });
      return false;
    }
    return true;
  }

  Future<bool> validateForm() async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    bool valid = scheduleFormKey.currentState!.validate();

    scheduleFormKey.currentState?.save();

    bool validName = await isNameValid();
    if (!valid || !(validName || continueAddingHere)) {
      return false;
    }

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
        tempSchedule.name != scheduleNameOnPageLoad &&
        !continueAddingHere) {
      scheduleList.renameSchedule(
        scheduleNameOnPageLoad,
        tempSchedule.name,
      );
    }

    tempSchedule.edit = false;
    await scheduleList.updateSchedule(tempSchedule);

    return true;
  }

  Future<void> addActivity(ScheduleActivity newActivity) async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    bool validName = await isNameValid();

    if (!(validName || continueAddingHere)) {
      return;
    }
    tempSchedule.activities.insert(
      0,
      newActivity,
    );

    scheduleList.addSchedule(tempSchedule, newActivity);
    //Navigator.of(context).pop();
    setState(() {});
  }

  //scheduleActivityInEditMode should not be null before calling this function.
  Future<void> updateActivity(ScheduleActivity newActivity) async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    bool validName = await isNameValid();

    if (!(validName || continueAddingHere)) {
      return;
    }

    await scheduleList.updateScheduleActivityByActivityId(
      tempSchedule,
      newActivity,
    );
    await scheduleList.updateActivity(newActivity.activity);
    setState(() {
      scheduleActivityInEditMode = null;
      updatingNextActivityAfterDuration = false;
    });
  }

  void onSubmitText() {
    setState(() {
      errorString = "";
    });

    bool validScheduleForm = scheduleFormKey.currentState!.validate();
    bool validDurationForm = durationFormKey.currentState?.validate() ?? true;
    if (!validScheduleForm || !validDurationForm) {
      return;
    }

    scheduleFormKey.currentState?.save();
    durationFormKey.currentState?.save();
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

    if (scheduleActivityInEditMode != null) {
      scheduleActivityInEditMode!.activity.title = addActivityController.text;
      scheduleActivityInEditMode!.edit = false;
      scheduleActivityInEditMode!.editNextActivity = false;
      scheduleActivityInEditMode!.activity.lastUpdatedAt = DateTime.now();
      if (updatingNextActivityAfterDuration) {
        scheduleActivityInEditMode!.nextActivityAfter = Duration(
          hours: activityDurationHour,
          minutes: activityDurationMinute,
          seconds: activityDurationSecond,
        );
      } else {
        scheduleActivityInEditMode!.activityDuration = Duration(
          hours: activityDurationHour,
          minutes: activityDurationMinute,
          seconds: activityDurationSecond,
        );
      }

      updateActivity(scheduleActivityInEditMode!);
    } else {
      addActivity(
        ScheduleActivity(
          activity: Activity(
            title: addActivityController.text,
            createdAt: DateTime.now(),
            lastUpdatedAt: DateTime.now(),
            activityId: const Uuid().v1(),
          ),
          activityDuration: Duration(
            hours: activityDurationHour,
            minutes: activityDurationMinute,
            seconds: activityDurationSecond,
          ),
        ),
      );

      FocusScope.of(context).requestFocus(addActivityFocus);
    }

    addActivityController.clear();
    setState(() {
      activityDurationHour = 0;
      activityDurationMinute = 0;
      activityDurationSecond = 0;
      addingDurationToActivity = false;
    });
  }

  String? validateMinuteOrSecond(String? value) {
    try {
      if (value == null || value == "") {
        return null;
      }
      int intValue = int.parse(value);
      if (intValue > 59 || intValue < 0) {
        return "00-59";
      }
      return null;
    } catch (e) {
      return "Number 00-59";
    }
  }

  String? validateHour(String? value) {
    try {
      if (value == null || value == "") {
        return null;
      }
      int intValue = int.parse(value);
      if (intValue > 23 || intValue < 0) {
        return "00-23";
      }
      return null;
    } catch (e) {
      return "Number 00-23";
    }
  }

  void undoEdit(ScheduleActivity scheduleActivity, bool forNextActivity) async {
    addActivityController.clear();
    scheduleActivityInEditMode = scheduleActivity;

    if (forNextActivity) {
      scheduleActivityInEditMode!.editNextActivity = false;
      scheduleActivityInEditMode!.edit = false;
    } else {
      scheduleActivityInEditMode!.editNextActivity = false;
      scheduleActivityInEditMode!.edit = false;
    }

    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);

    await scheduleList.resetActivities(tempSchedule);
    await scheduleList.updateScheduleActivityByActivityId(
        tempSchedule, scheduleActivityInEditMode!);

    setState(() {
      scheduleActivityInEditMode = null;
      addingDurationToActivity = false;
      activityDurationHour = 0;
      activityDurationMinute = 0;
      activityDurationSecond = 0;
      addingDurationToActivity = false;
      updatingNextActivityAfterDuration = false;
    });
  }

  void editActivity(
      ScheduleActivity scheduleActivity, bool forNextActivity) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    scheduleActivityInEditMode = scheduleActivity;

    if (forNextActivity) {
      scheduleActivityInEditMode!.editNextActivity = true;
      scheduleActivityInEditMode!.edit = false;
    } else {
      scheduleActivityInEditMode!.edit = true;
      scheduleActivityInEditMode!.editNextActivity = false;
    }

    await scheduleList.resetActivities(tempSchedule);
    await scheduleList.updateScheduleActivityByActivityId(
      tempSchedule,
      scheduleActivityInEditMode!,
    );
    updatingNextActivityAfterDuration = forNextActivity;
    Duration scheduleActivityDuration = forNextActivity
        ? scheduleActivity.nextActivityAfter
        : scheduleActivity.activityDuration;
    //if (scheduleActivityDuration.inSeconds != 0 || forNextActivity) {
    setState(() {
      addingDurationToActivity = true;
      activityDurationHour = scheduleActivityDuration.inHours;
      activityDurationMinute =
          scheduleActivityDuration.inMinutes - (activityDurationHour * 60);
      activityDurationSecond = scheduleActivityDuration.inSeconds -
          (activityDurationHour * 3600) -
          (activityDurationMinute * 60);
    });
    //}
    addActivityController.text = scheduleActivity.activity.title;
    if (!forNextActivity) {
      focusScope.requestFocus(addActivityFocus);
    }
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
              if (errorString != "")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorString,
                    style: TextStyle(color: Theme.of(context).errorColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (errorString != "" &&
                  errorString.contains("is already present"))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: const Text("Continue Adding here"),
                    onPressed: () {
                      setState(() {
                        continueAddingHere = true;
                        errorString = "";
                      });
                    },
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
                    editActivity: editActivity,
                    undoEdit: undoEdit,
                    error: errorString,
                  ),
                ),
              ),
              if (addingDurationToActivity)
                Form(
                  key: durationFormKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          initialValue: activityDurationHour == 0
                              ? null
                              : activityDurationHour.toString().padLeft(2, '0'),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            label: const Text("Hour"),
                            hintText:
                                activityDurationHour.toString().padLeft(2, '0'),
                          ),
                          onSaved: (newValue) => activityDurationHour =
                              newValue != "" && newValue != null
                                  ? int.parse(newValue)
                                  : 0,
                          validator: (value) => validateHour(value),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          initialValue: activityDurationMinute == 0
                              ? null
                              : activityDurationMinute
                                  .toString()
                                  .padLeft(2, '0'),
                          onSaved: (newValue) => activityDurationMinute =
                              newValue != "" && newValue != null
                                  ? int.parse(newValue)
                                  : 0,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            label: const Text(
                              "Minute",
                            ),
                            hintText: activityDurationMinute
                                .toString()
                                .padLeft(2, '0'),
                          ),
                          validator: (value) => validateMinuteOrSecond(value),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          initialValue: activityDurationSecond == 0
                              ? null
                              : activityDurationSecond
                                  .toString()
                                  .padLeft(2, '0'),
                          onSaved: (newValue) => activityDurationSecond =
                              newValue != "" && newValue != null
                                  ? int.parse(newValue)
                                  : 0,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            label: const Text("Second"),
                            hintText: activityDurationSecond
                                .toString()
                                .padLeft(2, '0'),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) => validateMinuteOrSecond(value),
                        ),
                      ),
                    ],
                  ),
                ),
              AppBar(
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Expanded(
                      child: updatingNextActivityAfterDuration
                          ? IconButton(
                              onPressed: onSubmitText,
                              icon: const Icon(Icons.done),
                            )
                          : TextField(
                              cursorColor: Theme.of(context).shadowColor,
                              focusNode: addActivityFocus,
                              decoration: InputDecoration(
                                label: const Text(
                                  'Add Task or Activity',
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                prefixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      addingDurationToActivity =
                                          !addingDurationToActivity;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.timelapse,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              controller: addActivityController,
                              onSubmitted: (_) {
                                onSubmitText();
                              },
                            ),
                    ),
                    if (!updatingNextActivityAfterDuration)
                      IconButton(
                        onPressed: onSubmitText,
                        icon: scheduleActivityInEditMode != null
                            ? const Icon(Icons.done_outline)
                            : const Icon(Icons.add_task_outlined),
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
