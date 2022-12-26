import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_activity.dart';
import 'package:schedule_it/models/schedule_list.dart';
//import 'package:schedule_it/screens/add_activity_screen.dart';
//import 'package:schedule_it/widgets/activities_timeline.dart';
import 'package:schedule_it/widgets/schedule_activities.dart';
import 'package:uuid/uuid.dart';

class AddScheduleScreen extends StatefulWidget {
  static String routename = "/add_schedules";

  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  Schedule tempSchedule = Schedule();
  Activity startActivity = Activity(
    activityId: const Uuid().v1(),
    title: systemStartActivityInTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemStartActivityInDB,
  );
  Activity restActivity = Activity(
    activityId: const Uuid().v1(),
    title: systemWaitActivityTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemWaitActivityInDB,
  );
  ScheduleActivity? scheduleActivityInEditMode;
  DateTime? scheduleStartTime;

  String pageTitle = "Add Schedule",
      activityTitle = "",
      errorString = "",
      scheduleNameOnPageLoad = "";

  bool addingDurationToActivity = false,
      addingScheduleToSchedule = false,
      updatingSystemWaitActivityInDB = false,
      pageInit = true;

  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0;

  final TextEditingController addActivityController = TextEditingController();
  final TextEditingController addStartTimeController = TextEditingController();

  //String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> scheduleFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> durationFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> startDateTimeInputKey = GlobalKey<FormState>();
  FocusNode addActivityFocus = FocusNode();

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
    if (nameExist) {
      setState(() {
        errorString = "Schedule name ${tempSchedule.name} is taken.";
      });
      return false;
    }
    return true;
  }

  Future<bool> validateForm() async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    if (scheduleFormKey.currentState == null) {
      return true;
    }
    bool valid = scheduleFormKey.currentState!.validate();

    scheduleFormKey.currentState?.save();

    bool validName = await isNameValid();
    if (!valid || !validName) {
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

    if (tempSchedule.at != null && tempSchedule.at!.isAfter(DateTime.now())) {
      Schedule scheduleInExecution =
          await scheduleList.moveScheduleToHistory(tempSchedule);
      scheduleList.scheduleNotificationForExecution(
          scheduleInExecution, scheduleInExecution.at!);
    } else {
      scheduleList.cancelScheduleNotification(tempSchedule);
    }

    //tempSchedule.name = pageTitle;

    if (tempSchedule.activities.isEmpty &&
        tempSchedule.name == "" &&
        scheduleNameOnPageLoad != "") {
      tempSchedule.name = scheduleNameOnPageLoad;
      scheduleList.removeSchedule(tempSchedule);
    }

    if (tempSchedule.activities.isNotEmpty &&
        tempSchedule.name != scheduleNameOnPageLoad) {
      scheduleList.renameSchedule(
        scheduleNameOnPageLoad,
        tempSchedule.name,
      );
    }

    if (!(tempSchedule.name == "" &&
        tempSchedule.activities.isEmpty &&
        scheduleNameOnPageLoad == "")) {
      tempSchedule.edit = false;
      await scheduleList.updateSchedule(tempSchedule);
      await scheduleList.updatScheduleActivityByScheduleName(tempSchedule);
    }
    return true;
  }

  Future<void> addActivity(ScheduleActivity newActivity) async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    ScheduleActivity restScheduleActivity = ScheduleActivity(
      activity: restActivity,
    );
    bool validName = await isNameValid();

    if (!(validName)) {
      return;
    }

    if (tempSchedule.activities.isEmpty) {
      ScheduleActivity startScheduleActivity = ScheduleActivity(
        activity: startActivity,
      );
      tempSchedule.activities.add(
        startScheduleActivity,
      );
      await scheduleList.addSchedule(
        tempSchedule,
        startScheduleActivity,
      );
    }
    tempSchedule.activities.add(
      newActivity,
    );

    await scheduleList.addSchedule(tempSchedule, newActivity);

    tempSchedule.activities.add(
      restScheduleActivity,
    );
    await scheduleList.addSchedule(
      tempSchedule,
      restScheduleActivity,
    );
    //Navigator.of(context).pop();
    setState(() {});
  }

  //scheduleActivityInEditMode should not be null before calling this function.
  Future<void> updateActivity(ScheduleActivity newActivity) async {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    bool validName = await isNameValid();

    if (!(validName)) {
      return;
    }

    await scheduleList.updateScheduleActivityByActivityId(
      tempSchedule,
      newActivity,
    );
    await scheduleList.updateActivity(newActivity.activity);
    setState(() {
      scheduleActivityInEditMode = null;
      updatingSystemWaitActivityInDB = false;
    });
  }

  void onSubmitText() {
    setState(() {
      errorString = "";
    });

    bool validScheduleForm = scheduleFormKey.currentState!.validate();
    bool validDurationForm = durationFormKey.currentState?.validate() ?? true;
    bool validStartDateTimeForm =
        startDateTimeInputKey.currentState?.validate() ?? true;
    if (!validScheduleForm || !validDurationForm || !validStartDateTimeForm) {
      return;
    }

    scheduleFormKey.currentState?.save();
    durationFormKey.currentState?.save();
    startDateTimeInputKey.currentState?.save();
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
      scheduleActivityInEditMode!.activity.lastUpdatedAt = DateTime.now();
      scheduleActivityInEditMode!.activityDuration = Duration(
        hours: activityDurationHour,
        minutes: activityDurationMinute,
        seconds: activityDurationSecond,
      );

      updateActivity(scheduleActivityInEditMode!);
      // if (scheduleActivityInEditMode?.activity.type ==
      //     systemStartActivityInDB) {
      //   Provider.of<ScheduleList>(context, listen: false)
      //       .updateSchedule(tempSchedule);
      // }
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
    addStartTimeController.clear();
    setState(() {
      activityDurationHour = 0;
      activityDurationMinute = 0;
      activityDurationSecond = 0;
      addingDurationToActivity = false;
      addingScheduleToSchedule = false;
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

  void undoEdit(ScheduleActivity scheduleActivity) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    addActivityController.clear();
    scheduleActivityInEditMode = scheduleActivity;
    scheduleActivityInEditMode!.edit = false;

    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);

    await scheduleList.resetSchedule(tempSchedule);
    await scheduleList.updateScheduleActivityByActivityId(
        tempSchedule, scheduleActivityInEditMode!);

    setState(() {
      scheduleActivityInEditMode = null;
      addingDurationToActivity = false;
      addingScheduleToSchedule = false;
      activityDurationHour = 0;
      activityDurationMinute = 0;
      updatingSystemWaitActivityInDB = false;
    });
    focusScope.unfocus();
  }

  void editActivity(ScheduleActivity scheduleActivity) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: false);
    await scheduleList.resetSchedule(tempSchedule);
    scheduleActivityInEditMode = scheduleActivity;

    scheduleActivityInEditMode!.edit = true;

    await scheduleList.updateScheduleActivityByActivityId(
      tempSchedule,
      scheduleActivityInEditMode!,
    );

    updatingSystemWaitActivityInDB =
        scheduleActivity.activity.type == systemWaitActivityInDB;

    Duration scheduleActivityDuration = scheduleActivity.activityDuration;

    if (scheduleActivity.activity.type == systemStartActivityInDB) {
      setState(() {
        addingScheduleToSchedule = true;
        addingDurationToActivity = false;
        scheduleStartTime = tempSchedule.at;
        addStartTimeController.text = scheduleStartTime != null
            ? DateFormat.yMEd().add_jms().format(scheduleStartTime!)
            : "";
      });
    } else {
      setState(() {
        addingScheduleToSchedule = false;
        addingDurationToActivity = true;
        activityDurationHour = scheduleActivityDuration.inHours;
        activityDurationMinute =
            scheduleActivityDuration.inMinutes - (activityDurationHour * 60);
        activityDurationSecond = scheduleActivityDuration.inSeconds -
            (activityDurationHour * 3600) -
            (activityDurationMinute * 60);
      });
    }
    addActivityController.text = scheduleActivity.activity.title;
    if (!updatingSystemWaitActivityInDB && !addingScheduleToSchedule) {
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

    // Autocomplete<String>(
    //   optionsBuilder: (TextEditingValue textEditingValue) async {
    //     if (textEditingValue.text == '') {
    //       return const Iterable<String>.empty();
    //     } else {
    //       List<Activity> matches = <Activity>[];
    //       final suggestions =
    //           await Provider.of<ScheduleList>(context, listen: false)
    //               .fetchActivities();
    //       matches.addAll(suggestions);

    //       matches.retainWhere((s) {
    //         return s.title
    //             .toLowerCase()
    //             .contains(textEditingValue.text.toLowerCase());
    //       });
    //       return matches.map((e) => e.title);
    //     }
    //   },
    // );

    final duraitonInputForm = Form(
      key: durationFormKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey(
                "${scheduleActivityInEditMode?.activity.title}_${scheduleActivityInEditMode?.index.toString()}_hours",
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.none,
              textAlign: TextAlign.center,
              initialValue: activityDurationHour == 0
                  ? null
                  : activityDurationHour.toString().padLeft(2, '0'),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Hour"),
                hintText: activityDurationHour.toString().padLeft(2, '0'),
              ),
              onSaved: (newValue) => activityDurationHour =
                  newValue != "" && newValue != null ? int.parse(newValue) : 0,
              validator: (value) => validateHour(value),
            ),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey(
                "${scheduleActivityInEditMode?.activity.title.toString()}_${scheduleActivityInEditMode?.index.toString()}_minutes",
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              initialValue: activityDurationMinute == 0
                  ? null
                  : activityDurationMinute.toString().padLeft(2, '0'),
              onSaved: (newValue) => activityDurationMinute =
                  newValue != "" && newValue != null ? int.parse(newValue) : 0,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text(
                  "Minute",
                ),
                hintText: activityDurationMinute.toString().padLeft(2, '0'),
              ),
              validator: (value) => validateMinuteOrSecond(value),
            ),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey(
                "${scheduleActivityInEditMode?.activity.title.toString()}_${scheduleActivityInEditMode?.index.toString()}_seconds",
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              initialValue: activityDurationSecond == 0
                  ? null
                  : activityDurationSecond.toString().padLeft(2, '0'),
              onSaved: (newValue) => activityDurationSecond =
                  newValue != "" && newValue != null ? int.parse(newValue) : 0,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text("Second"),
                hintText: activityDurationSecond.toString().padLeft(2, '0'),
                alignLabelWithHint: true,
              ),
              validator: (value) => validateMinuteOrSecond(value),
            ),
          ),
        ],
      ),
    );

    final startDateTimeInputForm = Form(
      key: startDateTimeInputKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: ValueKey(
            "${scheduleActivityInEditMode?.activity.title}_${scheduleActivityInEditMode?.index.toString()}",
          ),
          controller: addStartTimeController,
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(3000),
            );
            if (selectedDate == null) {
              return;
            }
            TimeOfDay initTime = TimeOfDay(
              hour: TimeOfDay.now().hour,
              minute: TimeOfDay.now().minute + 5,
            );
            TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: initTime,
                ) ??
                initTime;

            scheduleStartTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            addStartTimeController.text =
                DateFormat.yMEd().add_jms().format(scheduleStartTime!);
          },
          keyboardType: TextInputType.none,
          textInputAction: TextInputAction.none,
          textAlign: TextAlign.center,
          //initialValue: tempSchedule.at?.toIso8601String() ?? "",
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: const Text("Shedule Start Time"),
            hintText: activityDurationHour.toString().padLeft(2, '0'),
            suffixIcon: const Icon(Icons.calendar_month),
          ),
          validator: (value) {
            if (scheduleStartTime != null &&
                scheduleStartTime!.isAfter(DateTime.now())) {
              return null;
            } else {
              return "Select Date Time in Future";
            }
          },
          onSaved: (newValue) {
            tempSchedule.at = scheduleStartTime;
          },
        ),
      ),
    );

    final scheduleInputForm = Form(
      key: scheduleFormKey,
      child: Column(
        children: [
          TextFormField(
            autofocus: tempSchedule.name == "",
            textAlign: TextAlign.center,
            // style: TextStyle(
            //   color: Theme.of(context).cardColor,
            //   fontSize: 22,
            //   fontWeight: FontWeight.bold,
            // ),
            style: Theme.of(context).textTheme.headline6,
            decoration: const InputDecoration(
              border: InputBorder.none,
              floatingLabelAlignment: FloatingLabelAlignment.center,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              label: Center(
                child: Text(
                  "Unique Schedule Name",
                ),
              ),
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
            onFieldSubmitted: (value) =>
                FocusScope.of(context).requestFocus(addActivityFocus),
          ),
        ],
      ),
    );

    // final appBarWidget = AppBar(
    //   centerTitle: true,
    //   title: scheduleInputForm,
    //   actions: const [],
    // );

    // double appHeight = MediaQuery.of(context).size.height -
    //     appBarWidget.preferredSize.height -
    //     MediaQuery.of(context).viewPadding.top;

    return WillPopScope(
      onWillPop: validateForm,
      child: Scaffold(
        //appBar: appBarWidget,
        body: SafeArea(
          child: SizedBox(
            //height: appHeight,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (errorString != "")
                  Divider(
                    thickness: 0,
                    color: Theme.of(context).dividerTheme.color,
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ScheduleActivities(
                      tempSchedule: tempSchedule,
                      editActivity: editActivity,
                      undoEdit: undoEdit,
                    ),
                  ),
                ),
                scheduleInputForm,
                if (addingDurationToActivity) duraitonInputForm,
                if (addingScheduleToSchedule) startDateTimeInputForm,
                AppBar(
                  automaticallyImplyLeading: !updatingSystemWaitActivityInDB &&
                      !addingScheduleToSchedule &&
                      MediaQuery.of(context).viewInsets.bottom == 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (!updatingSystemWaitActivityInDB &&
                          !addingScheduleToSchedule)
                        Expanded(
                          child: TextField(
                            cursorColor: Theme.of(context).shadowColor,
                            focusNode: addActivityFocus,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
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
                                icon: Icon(
                                  Icons.timelapse,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ),
                            controller: addActivityController,
                            onSubmitted: (_) {
                              onSubmitText();
                            },
                          ),
                        ),
                      if (updatingSystemWaitActivityInDB ||
                          addingScheduleToSchedule)
                        IconButton(
                          onPressed: () {
                            undoEdit(scheduleActivityInEditMode!);
                          },
                          icon: const Icon(Icons.cancel_outlined),
                        ),
                      IconButton(
                        onPressed: onSubmitText,
                        icon: scheduleActivityInEditMode != null
                            ? const Icon(Icons.done_outline)
                            : updatingSystemWaitActivityInDB
                                ? const Icon(Icons.done)
                                : const Icon(Icons.add_task_outlined),
                      ),
                    ],
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
