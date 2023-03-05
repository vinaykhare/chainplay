import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
//import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
//import 'package:chain_activities/screens/add_activity_screen.dart';
//import 'package:chain_activities/widgets/activities_timeline.dart';
import 'package:chain_activities/widgets/chain_activities_widget.dart';
import 'package:uuid/uuid.dart';

class AddChainScreen extends StatefulWidget {
  static String routename = "/add_chains";

  const AddChainScreen({super.key});

  @override
  State<AddChainScreen> createState() => _AddChainScreenState();
}

class _AddChainScreenState extends State<AddChainScreen> {
  Chain tempChain = Chain();
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
  ChainActivity? chainActivityInEditMode;
  DateTime? chainStartTime, chainStartDate;
  int? chainRepeatCount;

  String pageTitle = "Add Chain",
      activityTitle = "",
      errorString = "",
      chainNameOnPageLoad = "";

  bool showSaveAndExit = false,
      addingDurationToActivity = false,
      addingScheduleToChain = false,
      updatingSystemWaitActivityInDB = false,
      pageInit = true;

  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0;

  final TextEditingController addActivityController = TextEditingController();
  final TextEditingController addStartDateController = TextEditingController();
  final TextEditingController addStartTimeController = TextEditingController();
  final TextEditingController activityImageController = TextEditingController();
  final List<String> repeatTypes = [
    repeatTypeDoesNotRepeat,
    repeatTypeSecond,
    repeatTypeMinute,
    repeatTypeHourly,
    repeatTypeDaily,
    repeatTypeWeekly,
    repeatTypeMonthly,
    repeatTypeYearly,
  ];
  final List<String> repeatOccur = [
    repeatOccurAfter,
    repeatOccurNever,
  ];
  int repeatTypeGap = repeatTypeDefaultGap;
  int repeatCount = repeatTypeDefaultCount;
  //String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> chainFormKey = GlobalKey<FormState>();
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
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    bool nameExist = await chainList.nameExistInDB(tempChain.title);
    if (nameExist) {
      setState(() {
        errorString = "Chain name ${tempChain.title} is taken.";
      });
      return false;
    }
    return true;
  }

  Future<void> saveAndExit() async {
    NavigatorState navigatorState = Navigator.of(context);
    await validateForm();
    navigatorState.pushReplacementNamed(ChainListScreen.routename);
  }

  Future<bool> validateForm() async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    if (chainFormKey.currentState == null) {
      return true;
    }
    bool valid = chainFormKey.currentState!.validate();

    chainFormKey.currentState?.save();

    bool validName = await isNameValid();
    if (!valid || !validName) {
      return false;
    }

    if (tempChain.activities.isNotEmpty && tempChain.title == "") {
      setState(() {
        errorString =
            "Give a valid name to this Chain!\n OR\n Remove all Activites to delete the Chain.";
      });
      return false;
    }

    if (tempChain.activities.isEmpty && tempChain.title != "") {
      setState(() {
        errorString = "Add atleast one activity to this Chain.";
      });
      return false;
    }

    if (tempChain.at != null && tempChain.at!.isAfter(DateTime.now())) {
      Chain chainInExecution = await chainList.startChainExecution(tempChain);
      await chainList.scheduleNotificationForExecution(
          chainInExecution, chainInExecution.at!);

      tempChain.notificationId = trueInDB;

      //await chainList.evaluateChainExecutions(tempChain, false);
    }
    // else {
    //   chainList.cancelScheduledNotification(tempChain);
    // }

    //tempChain.name = pageTitle;

    if (tempChain.activities.isEmpty &&
        tempChain.title == "" &&
        chainNameOnPageLoad != "") {
      tempChain.title = chainNameOnPageLoad;
      chainList.removeChain(tempChain);
    }

    if (tempChain.activities.isNotEmpty &&
        tempChain.title != chainNameOnPageLoad) {
      chainList.renameChain(
        chainNameOnPageLoad,
        tempChain.title,
      );
    }

    if (!(tempChain.title == "" &&
        tempChain.activities.isEmpty &&
        chainNameOnPageLoad == "")) {
      tempChain.edit = false;
      await chainList.updateChain(tempChain);
      await chainList.updatChainActivityByChainName(tempChain);
    }
    return true;
  }

  Future<void> addActivity(ChainActivity newActivity) async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    ChainActivity restChainActivity = ChainActivity(
      activity: restActivity,
    );
    bool validName = await isNameValid();

    if (!(validName)) {
      return;
    }

    if (tempChain.activities.isEmpty) {
      ChainActivity startChainActivity = ChainActivity(
        activity: startActivity,
      );
      startChainActivity.index = 0;
      tempChain.activities.add(
        startChainActivity,
      );
      await chainList.addChain(
        tempChain,
        startChainActivity,
      );
    }
    tempChain.activities.add(
      newActivity,
    );

    await chainList.addChain(tempChain, newActivity);

    tempChain.activities.add(
      restChainActivity,
    );
    await chainList.addChain(
      tempChain,
      restChainActivity,
    );
    //Navigator.of(context).pop();
    setState(() {});
  }

  //chainActivityInEditMode should not be null before calling this function.
  Future<void> updateActivity(ChainActivity newActivity) async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    bool validName = await isNameValid();

    if (!(validName)) {
      return;
    }

    await chainList.updateChainActivityByActivityId(
      tempChain,
      newActivity,
    );
    await chainList.updateActivity(newActivity.activity);
    setState(() {
      chainActivityInEditMode = null;
      updatingSystemWaitActivityInDB = false;
    });
  }

  void onSubmitText() {
    setState(() {
      errorString = "";
    });

    bool validChainForm = chainFormKey.currentState!.validate();
    bool validDurationForm = durationFormKey.currentState?.validate() ?? true;
    bool validStartDateTimeForm =
        startDateTimeInputKey.currentState?.validate() ?? true;
    if (!validChainForm || !validDurationForm || !validStartDateTimeForm) {
      return;
    }

    chainFormKey.currentState?.save();
    durationFormKey.currentState?.save();
    startDateTimeInputKey.currentState?.save();
    if (tempChain.title == "") {
      setState(() {
        errorString =
            "Please insert the Chain name before adding activity to it.";
      });
      return;
    }
    if (addActivityController.text.isEmpty) {
      return;
    }

    if (chainActivityInEditMode != null) {
      chainActivityInEditMode!.activity.title = addActivityController.text;
      chainActivityInEditMode!.edit = false;
      chainActivityInEditMode!.activity.lastUpdatedAt = DateTime.now();
      chainActivityInEditMode!.activityDuration = Duration(
        hours: activityDurationHour,
        minutes: activityDurationMinute,
        seconds: activityDurationSecond,
      );
      if (activityImageController.text.isNotEmpty) {
        chainActivityInEditMode!.activity.specification = {
          activitySpecImagePath: activityImageController.text,
        };
      }

      updateActivity(chainActivityInEditMode!);
      // if (chainActivityInEditMode?.activity.type ==
      //     systemStartActivityInDB) {
      //   Provider.of<ChainList>(context, listen: false)
      //       .updateChain(tempChain);
      // }
    } else {
      addActivity(
        ChainActivity(
          activity: Activity(
            title: addActivityController.text,
            createdAt: DateTime.now(),
            lastUpdatedAt: DateTime.now(),
            activityId: const Uuid().v1(),
            specification: activityImageController.text.isNotEmpty
                ? {
                    activitySpecImagePath: activityImageController.text,
                  }
                : {},
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
    addStartDateController.clear();
    addStartTimeController.clear();
    activityImageController.clear();
    setState(() {
      activityDurationHour = 0;
      activityDurationMinute = 0;
      activityDurationSecond = 0;
      addingDurationToActivity = false;
      addingScheduleToChain = false;
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

  void undoEdit(ChainActivity chainActivity) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    addActivityController.clear();
    activityImageController.clear();
    addStartDateController.clear();
    addStartTimeController.clear();
    chainActivityInEditMode = chainActivity;
    chainActivityInEditMode!.edit = false;

    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    //await chainList.resetChain(tempChain);
    await chainList.updateChainActivityByActivityId(
        tempChain, chainActivityInEditMode!);

    setState(() {
      chainActivityInEditMode = null;
      addingDurationToActivity = false;
      addingScheduleToChain = false;
      activityDurationHour = 0;
      activityDurationMinute = 0;
      updatingSystemWaitActivityInDB = false;
    });
    focusScope.unfocus();
  }

  void editActivity(ChainActivity chainActivity) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    //await chainList.resetChain(tempChain);
    chainActivityInEditMode = chainActivity;

    chainActivityInEditMode!.edit = true;

    await chainList.updateChainActivityByActivityId(
      tempChain,
      chainActivityInEditMode!,
    );

    updatingSystemWaitActivityInDB =
        chainActivityInEditMode!.activity.type == systemWaitActivityInDB;

    Duration chainActivityDuration = chainActivityInEditMode!.activityDuration;

    if (chainActivity.activity.type == systemStartActivityInDB) {
      setState(() {
        addingScheduleToChain = true;
        addingDurationToActivity = false;
        chainStartDate = tempChain.at;
        chainStartTime = tempChain.at;
        addStartDateController.text = chainStartDate != null
            ? DateFormat.yMEd().format(chainStartDate!)
            : "";
        addStartTimeController.text = chainStartTime != null
            ? DateFormat.jms().format(chainStartTime!)
            : "";
      });
      if (tempChain.at == null) {
        await pickTime();
      }
    } else {
      setState(() {
        addingScheduleToChain = false;
        addingDurationToActivity = true;
        activityDurationHour = chainActivityDuration.inHours;
        activityDurationMinute =
            chainActivityDuration.inMinutes - (activityDurationHour * 60);
        activityDurationSecond = chainActivityDuration.inSeconds -
            (activityDurationHour * 3600) -
            (activityDurationMinute * 60);
        activityImageController.text = chainActivityInEditMode!
                .activity.specification?[activitySpecImagePath] ??
            "";
      });
    }
    addActivityController.text = chainActivity.activity.title;
    if (!updatingSystemWaitActivityInDB && !addingScheduleToChain) {
      focusScope.requestFocus(addActivityFocus);
    }
  }

  Future<void> pickDate() async {
    chainStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
    );
    if (chainStartDate == null) {
      return;
    }
    addStartDateController.text = DateFormat.yMEd().format(chainStartDate!);
    // TimeOfDay initTime = TimeOfDay.fromDateTime(
    //     DateTime.now().add(const Duration(minutes: 1)));
    // // TimeOfDay initTime = TimeOfDay(
    // //   hour: TimeOfDay.now().hour,
    // //   minute: TimeOfDay.now().minute + 5,
    // // );
    // TimeOfDay? selectedTime = await showTimePicker(
    //       context: context,
    //       initialTime: initTime,
    //     ) ??
    //     initTime;

    // chainStartTime = DateTime(
    //   selectedDate.year,
    //   selectedDate.month,
    //   selectedDate.day,
    //   selectedTime.hour,
    //   selectedTime.minute,
    // );
    // addStartTimeController.text =
    //     DateFormat.yMEd().add_jms().format(chainStartTime!);
  }

  Future<void> pickTime() async {
    TimeOfDay initTime =
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 1)));
    TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: initTime,
        ) ??
        initTime;

    chainStartDate ??= DateTime.now();
    addStartDateController.text = DateFormat.yMEd().format(chainStartDate!);
    chainStartTime = DateTime(
      chainStartDate!.year,
      chainStartDate!.month,
      chainStartDate!.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    setState(() {
      addStartTimeController.text = DateFormat.jms().format(chainStartTime!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempChain = ModalRoute.of(context)?.settings.arguments as Chain;
        pageTitle = tempChain.title;
        chainNameOnPageLoad = tempChain.title;
        //tempChain.loadActivities();

        repeatTypes.remove(tempChain.repeatType);
        repeatTypes.insert(0, tempChain.repeatType);

        if (tempChain.activities.length == 1) {
          editActivity(tempChain.activities[0]);
        }
      } else {
        showSaveAndExit = true;
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
    //           await Provider.of<ChainList>(context, listen: false)
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    "${chainActivityInEditMode?.activity.title}_${chainActivityInEditMode?.index.toString()}_hours",
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
                      newValue != "" && newValue != null
                          ? int.parse(newValue)
                          : 0,
                  validator: (value) => validateHour(value),
                ),
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    "${chainActivityInEditMode?.activity.title.toString()}_${chainActivityInEditMode?.index.toString()}_minutes",
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  initialValue: activityDurationMinute == 0
                      ? null
                      : activityDurationMinute.toString().padLeft(2, '0'),
                  onSaved: (newValue) => activityDurationMinute =
                      newValue != "" && newValue != null
                          ? int.parse(newValue)
                          : 0,
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
                    "${chainActivityInEditMode?.activity.title.toString()}_${chainActivityInEditMode?.index.toString()}_seconds",
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  initialValue: activityDurationSecond == 0
                      ? null
                      : activityDurationSecond.toString().padLeft(2, '0'),
                  onSaved: (newValue) => activityDurationSecond =
                      newValue != "" && newValue != null
                          ? int.parse(newValue)
                          : 0,
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
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    "${chainActivityInEditMode?.activity.title.toString()}_${chainActivityInEditMode?.index.toString()}_image",
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  controller: activityImageController,
                  // onSaved: (_) => chainActivityInEditMode!
                  //         .activity.specification![activitySpecImagePath] =
                  //     activityImageController.text,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Image Path"),
                    hintText: activityDurationSecond.toString().padLeft(2, '0'),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.browse_gallery),
                onPressed: () async {
                  XFile? pickedImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    activityImageController.text = pickedImage.path;
                  }
                },
              ),
            ],
          )
        ],
      ),
    );

    final startDateTimeInputForm = Form(
      key: startDateTimeInputKey,
      child: Column(
        key: ValueKey(
          "${chainActivityInEditMode?.activity.title}_${chainActivityInEditMode?.index.toString()}",
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: addStartDateController,
                  onTap: pickDate,
                  keyboardType: TextInputType.none,
                  textInputAction: TextInputAction.none,
                  textAlign: TextAlign.center,
                  //initialValue: tempChain.at?.toIso8601String() ?? "",
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Chain Execution Date"),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                  // validator: (value) {
                  //   if (chainStartDate != null &&
                  //       (chainStartDate!.isAfter(
                  //             DateTime.now(),
                  //           ) ||
                  //           chainStartDate!.isAtSameMomentAs(
                  //             DateTime.now(),
                  //           ))) {
                  //     return null;
                  //   } else {
                  //     return "Select Date in Future";
                  //   }
                  // },
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: addStartTimeController,
                  onTap: pickTime,
                  keyboardType: TextInputType.none,
                  textInputAction: TextInputAction.none,
                  textAlign: TextAlign.center,
                  //initialValue: tempChain.at?.toIso8601String() ?? "",
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Chain Execution Time"),
                    hintText: activityDurationHour.toString().padLeft(2, '0'),
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                  validator: (value) {
                    if (chainStartTime != null &&
                        chainStartTime!.isAfter(DateTime.now())) {
                      return null;
                    } else {
                      return "Select Time in Future";
                    }
                  },
                  onSaved: (newValue) {
                    chainStartTime = DateTime(
                      chainStartDate!.year,
                      chainStartDate!.month,
                      chainStartDate!.day,
                      chainStartTime!.hour,
                      chainStartTime!.minute,
                    );
                    tempChain.at = chainStartTime;
                    tempChain.repeatType = repeatTypes[0];
                    tempChain.repeatCount = repeatTypeGap;
                    tempChain.repeatCount = repeatCount;
                  },
                ),
              ),
            ],
          ),
          if (addStartTimeController.text.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    textInputAction: TextInputAction.none,
                    keyboardType: TextInputType.none,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      label: Center(
                        child: Text(
                          repeatTypes[0] != repeatTypeDoesNotRepeat
                              ? 'Repeat every'
                              : 'Repeat',
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ),
                ),
                if (repeatTypes[0] != repeatTypeDoesNotRepeat)
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: tempChain.repeatTypeGap.toString(),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      validator: (value) {
                        try {
                          if (value != null &&
                              int.parse(value) ==
                                  int.parse(value).roundToDouble()) {
                            if (int.parse(value) > 0) {
                              return null;
                            } else {
                              return "1 or Greater";
                            }
                          } else {
                            return "Give valid integer value.";
                          }
                        } catch (e) {
                          return "Insert valid integer value";
                        }
                      },
                      onSaved: (newValue) => tempChain.repeatTypeGap =
                          newValue == null
                              ? repeatTypeDefaultGap
                              : int.parse(newValue),
                    ),
                  ),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: repeatTypes[0],
                    onChanged: (String? value) async {
                      if (value == null || value == "") {
                        return;
                      }
                      repeatTypes.remove(value);
                      repeatTypes.insert(0, value);
                      if (repeatTypes[0] == repeatTypeDoesNotRepeat) {
                        tempChain.repeatCount = repeatTypeDefaultCount;
                      } else {
                        tempChain.repeatCount = 2;
                      }
                    },
                    items: repeatTypes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        alignment: Alignment.center,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          if (repeatTypes[0] != repeatTypeDoesNotRepeat &&
              addStartTimeController.text.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    textInputAction: TextInputAction.none,
                    keyboardType: TextInputType.none,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      label: Center(
                        child: Text(
                          "Repeat ends after",
                        ),
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   child: DropdownButton<String>(
                //     isExpanded: true,
                //     value: repeatOccur[0],
                //     onChanged: (String? value) async {
                //       if (value == null || value == "") {
                //         return;
                //       }
                //       repeatOccur.remove(value);
                //       repeatOccur.insert(0, value);
                //       if (value == repeatOccurNever) {
                //         tempChain.repeatCount = repeatTypeDefaultCount;
                //       } else {
                //         tempChain.repeatCount = 2;
                //       }
                //     },
                //     items: repeatOccur
                //         .map<DropdownMenuItem<String>>((String value) {
                //       return DropdownMenuItem<String>(
                //         value: value,
                //         alignment: Alignment.center,
                //         child: Text(
                //           value,
                //           textAlign: TextAlign.center,
                //         ),
                //       );
                //     }).toList(),
                //   ),
                // ),
                if (repeatOccur[0] == repeatOccurAfter)
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: tempChain.repeatCount == -1
                          ? "infinite"
                          : tempChain.repeatCount.toString(),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      validator: (value) {
                        try {
                          if (value == "infinite") {
                            return null;
                          }
                          if (value != null &&
                              int.parse(value) ==
                                  int.parse(value).roundToDouble()) {
                            if (int.parse(value) > 0) {
                              return null;
                            } else {
                              return "1 or Greater";
                            }
                          } else {
                            return "Give valid integer value";
                          }
                        } catch (e) {
                          return "Insert valid integer value";
                        }
                      },
                      onSaved: (newValue) =>
                          tempChain.repeatCount = newValue == null
                              ? repeatTypeDefaultCount
                              : newValue == "infinite"
                                  ? -1
                                  : int.parse(newValue),
                    ),
                  ),
                //if (repeatOccur[0] == repeatOccurAfter)
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    textInputAction: TextInputAction.none,
                    keyboardType: TextInputType.none,
                    textAlign: TextAlign.start,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      label: Center(
                        child: Text(
                          "occurances.",
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    final chainInputForm = Form(
      key: chainFormKey,
      child: Column(
        children: [
          TextFormField(
            autofocus: tempChain.title == "",
            textAlign: TextAlign.center,
            // style: TextStyle(
            //   color: Theme.of(context).cardColor,
            //   fontSize: 22,
            //   fontWeight: FontWeight.bold,
            // ),
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              border: InputBorder.none,
              floatingLabelAlignment: FloatingLabelAlignment.center,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              label: Center(
                child: Text(
                  "Unique Chain Name",
                ),
              ),
            ),
            initialValue: tempChain.title,
            validator: (value) {
              if ((value == null || value == "") &&
                  tempChain.activities.isNotEmpty) {
                return "Inesrt valid Chain Name";
              }
              return null;
            },
            onSaved: (value) {
              tempChain.title = value ?? "";
            },
            onFieldSubmitted: (value) =>
                FocusScope.of(context).requestFocus(addActivityFocus),
          ),
        ],
      ),
    );

    // final appBarWidget = AppBar(
    //   centerTitle: true,
    //   title: chainInputForm,
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
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
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
                    child: ChainActivitiesWidget(
                      tempChain: tempChain,
                      editActivity: editActivity,
                      undoEdit: undoEdit,
                    ),
                  ),
                ),
                chainInputForm,
                if (addingDurationToActivity) duraitonInputForm,
                if (addingScheduleToChain) startDateTimeInputForm,
                AppBar(
                  automaticallyImplyLeading: !updatingSystemWaitActivityInDB &&
                      !addingScheduleToChain &&
                      MediaQuery.of(context).viewInsets.bottom == 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (showSaveAndExit &&
                          MediaQuery.of(context).viewInsets.bottom == 0)
                        IconButton(
                          onPressed: saveAndExit,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      if (!updatingSystemWaitActivityInDB &&
                          !addingScheduleToChain)
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
                          addingScheduleToChain)
                        IconButton(
                          onPressed: () {
                            undoEdit(chainActivityInEditMode!);
                            // tempChain.at = null;
                            // tempChain.repeatType = repeatTypeDoesNotRepeat;
                            // tempChain.repeatCount = repeatTypeDefaultCount;
                          },
                          icon: const Icon(Icons.cancel_outlined),
                        ),
                      if (addingScheduleToChain && tempChain.at != null)
                        TextButton(
                          onPressed: () {
                            undoEdit(chainActivityInEditMode!);
                            tempChain.at = null;
                            tempChain.repeatType = repeatTypeDoesNotRepeat;
                            tempChain.repeatCount = repeatTypeDefaultCount;
                          },
                          child: CircleAvatar(
                            radius: 50,
                            child: Text(
                              "Remove\nAlarm",
                              style: Theme.of(context).textTheme.labelSmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      IconButton(
                        onPressed: onSubmitText,
                        icon: chainActivityInEditMode != null
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
