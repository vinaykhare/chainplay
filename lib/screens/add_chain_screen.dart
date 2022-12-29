import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
//import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/models/event.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/chain_event.dart';
import 'package:chain_events/models/chain_list.dart';
//import 'package:chain_events/screens/add_event_screen.dart';
//import 'package:chain_events/widgets/activities_timeline.dart';
import 'package:chain_events/widgets/chain_events_widget.dart';
import 'package:uuid/uuid.dart';

class AddChainScreen extends StatefulWidget {
  static String routename = "/add_chains";

  const AddChainScreen({super.key});

  @override
  State<AddChainScreen> createState() => _AddChainScreenState();
}

class _AddChainScreenState extends State<AddChainScreen> {
  Chain tempChain = Chain();
  Event startEvent = Event(
    eventId: const Uuid().v1(),
    title: systemStartEventInTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemStartEventInDB,
  );
  Event restEvent = Event(
    eventId: const Uuid().v1(),
    title: systemWaitEventTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemWaitEventInDB,
  );
  ChainEvent? chainEventInEditMode;
  DateTime? chainStartTime, chainStartDate;
  int? chainRepeatCount;

  String pageTitle = "Add Chain",
      eventTitle = "",
      errorString = "",
      chainNameOnPageLoad = "";

  bool addingDurationToEvent = false,
      addingScheduleToChain = false,
      updatingSystemWaitEventInDB = false,
      pageInit = true;

  int eventDurationHour = 0, eventDurationMinute = 0, eventDurationSecond = 0;

  final TextEditingController addEventController = TextEditingController();
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
    repeatOccurNever,
    repeatOccurAfter,
  ];
  int repeatTypeGap = repeatTypeDefaultGap;
  int repeatCount = repeatTypeDefaultCount;
  //String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> chainFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> durationFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> startDateTimeInputKey = GlobalKey<FormState>();
  FocusNode addEventFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    addEventFocus.dispose();
    addEventController.dispose();
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
        errorString = "Add atleast one event to this Chain.";
      });
      return false;
    }

    if (tempChain.at != null && tempChain.at!.isAfter(DateTime.now())) {
      Chain chainInExecution = await chainList.startChainExecution(tempChain);
      chainList.scheduleNotificationForExecution(
          chainInExecution, chainInExecution.at!);
    } else {
      chainList.cancelScheduledNotification(tempChain);
    }

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
      await chainList.updatChainEventByChainName(tempChain);
    }
    return true;
  }

  Future<void> addEvent(ChainEvent newEvent) async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    ChainEvent restChainEvent = ChainEvent(
      event: restEvent,
    );
    bool validName = await isNameValid();

    if (!(validName)) {
      return;
    }

    if (tempChain.activities.isEmpty) {
      ChainEvent startChainEvent = ChainEvent(
        event: startEvent,
      );
      tempChain.activities.add(
        startChainEvent,
      );
      await chainList.addChain(
        tempChain,
        startChainEvent,
      );
    }
    tempChain.activities.add(
      newEvent,
    );

    await chainList.addChain(tempChain, newEvent);

    tempChain.activities.add(
      restChainEvent,
    );
    await chainList.addChain(
      tempChain,
      restChainEvent,
    );
    //Navigator.of(context).pop();
    setState(() {});
  }

  //chainEventInEditMode should not be null before calling this function.
  Future<void> updateEvent(ChainEvent newEvent) async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    bool validName = await isNameValid();

    if (!(validName)) {
      return;
    }

    await chainList.updateChainEventByEventId(
      tempChain,
      newEvent,
    );
    await chainList.updateEvent(newEvent.event);
    setState(() {
      chainEventInEditMode = null;
      updatingSystemWaitEventInDB = false;
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
        errorString = "Please insert the Chain name before adding event to it.";
      });
      return;
    }
    if (addEventController.text.isEmpty) {
      return;
    }

    if (chainEventInEditMode != null) {
      chainEventInEditMode!.event.title = addEventController.text;
      chainEventInEditMode!.edit = false;
      chainEventInEditMode!.event.lastUpdatedAt = DateTime.now();
      chainEventInEditMode!.eventDuration = Duration(
        hours: eventDurationHour,
        minutes: eventDurationMinute,
        seconds: eventDurationSecond,
      );
      if (activityImageController.text.isNotEmpty) {
        chainEventInEditMode!.event.specification = {
          activitySpecImagePath: activityImageController.text,
        };
      }

      updateEvent(chainEventInEditMode!);
      // if (chainEventInEditMode?.event.type ==
      //     systemStartEventInDB) {
      //   Provider.of<ChainList>(context, listen: false)
      //       .updateChain(tempChain);
      // }
    } else {
      addEvent(
        ChainEvent(
          event: Event(
            title: addEventController.text,
            createdAt: DateTime.now(),
            lastUpdatedAt: DateTime.now(),
            eventId: const Uuid().v1(),
            specification: activityImageController.text.isNotEmpty
                ? {
                    activitySpecImagePath: activityImageController.text,
                  }
                : {},
          ),
          eventDuration: Duration(
            hours: eventDurationHour,
            minutes: eventDurationMinute,
            seconds: eventDurationSecond,
          ),
        ),
      );

      FocusScope.of(context).requestFocus(addEventFocus);
    }

    addEventController.clear();
    addStartDateController.clear();
    addStartTimeController.clear();
    activityImageController.clear();
    setState(() {
      eventDurationHour = 0;
      eventDurationMinute = 0;
      eventDurationSecond = 0;
      addingDurationToEvent = false;
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

  void undoEdit(ChainEvent chainEvent) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    addEventController.clear();
    activityImageController.clear();
    addStartDateController.clear();
    addStartTimeController.clear();
    chainEventInEditMode = chainEvent;
    chainEventInEditMode!.edit = false;

    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    //await chainList.resetChain(tempChain);
    await chainList.updateChainEventByEventId(tempChain, chainEventInEditMode!);

    setState(() {
      chainEventInEditMode = null;
      addingDurationToEvent = false;
      addingScheduleToChain = false;
      eventDurationHour = 0;
      eventDurationMinute = 0;
      updatingSystemWaitEventInDB = false;
    });
    focusScope.unfocus();
  }

  void editEvent(ChainEvent chainEvent) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    //await chainList.resetChain(tempChain);
    chainEventInEditMode = chainEvent;

    chainEventInEditMode!.edit = true;

    await chainList.updateChainEventByEventId(
      tempChain,
      chainEventInEditMode!,
    );

    updatingSystemWaitEventInDB =
        chainEventInEditMode!.event.type == systemWaitEventInDB;

    Duration chainEventDuration = chainEventInEditMode!.eventDuration;

    if (chainEvent.event.type == systemStartEventInDB) {
      setState(() {
        addingScheduleToChain = true;
        addingDurationToEvent = false;
        chainStartDate = tempChain.at;
        chainStartTime = tempChain.at;
        addStartDateController.text = chainStartDate != null
            ? DateFormat.yMEd().format(chainStartDate!)
            : "";
        addStartTimeController.text = chainStartTime != null
            ? DateFormat.jms().format(chainStartTime!)
            : "";
      });
    } else {
      setState(() {
        addingScheduleToChain = false;
        addingDurationToEvent = true;
        eventDurationHour = chainEventDuration.inHours;
        eventDurationMinute =
            chainEventDuration.inMinutes - (eventDurationHour * 60);
        eventDurationSecond = chainEventDuration.inSeconds -
            (eventDurationHour * 3600) -
            (eventDurationMinute * 60);
        activityImageController.text =
            chainEventInEditMode!.event.specification?[activitySpecImagePath] ??
                "";
      });
    }
    addEventController.text = chainEvent.event.title;
    if (!updatingSystemWaitEventInDB && !addingScheduleToChain) {
      focusScope.requestFocus(addEventFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempChain = ModalRoute.of(context)?.settings.arguments as Chain;
        pageTitle = tempChain.title;
        chainNameOnPageLoad = tempChain.title;
        //tempChain.loadActivities();
      }
      pageInit = false;
      //FocusScope.of(context).requestFocus(addEventFocus);
    }

    // Autocomplete<String>(
    //   optionsBuilder: (TextEditingValue textEditingValue) async {
    //     if (textEditingValue.text == '') {
    //       return const Iterable<String>.empty();
    //     } else {
    //       List<Event> matches = <Event>[];
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
                    "${chainEventInEditMode?.event.title}_${chainEventInEditMode?.index.toString()}_hours",
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.none,
                  textAlign: TextAlign.center,
                  initialValue: eventDurationHour == 0
                      ? null
                      : eventDurationHour.toString().padLeft(2, '0'),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Hour"),
                    hintText: eventDurationHour.toString().padLeft(2, '0'),
                  ),
                  onSaved: (newValue) => eventDurationHour =
                      newValue != "" && newValue != null
                          ? int.parse(newValue)
                          : 0,
                  validator: (value) => validateHour(value),
                ),
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    "${chainEventInEditMode?.event.title.toString()}_${chainEventInEditMode?.index.toString()}_minutes",
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  initialValue: eventDurationMinute == 0
                      ? null
                      : eventDurationMinute.toString().padLeft(2, '0'),
                  onSaved: (newValue) => eventDurationMinute =
                      newValue != "" && newValue != null
                          ? int.parse(newValue)
                          : 0,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text(
                      "Minute",
                    ),
                    hintText: eventDurationMinute.toString().padLeft(2, '0'),
                  ),
                  validator: (value) => validateMinuteOrSecond(value),
                ),
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey(
                    "${chainEventInEditMode?.event.title.toString()}_${chainEventInEditMode?.index.toString()}_seconds",
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  initialValue: eventDurationSecond == 0
                      ? null
                      : eventDurationSecond.toString().padLeft(2, '0'),
                  onSaved: (newValue) => eventDurationSecond =
                      newValue != "" && newValue != null
                          ? int.parse(newValue)
                          : 0,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Second"),
                    hintText: eventDurationSecond.toString().padLeft(2, '0'),
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
                    "${chainEventInEditMode?.event.title.toString()}_${chainEventInEditMode?.index.toString()}_image",
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  controller: activityImageController,
                  onSaved: (_) => chainEventInEditMode!
                          .event.specification![activitySpecImagePath] =
                      activityImageController.text,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Image Path"),
                    hintText: eventDurationSecond.toString().padLeft(2, '0'),
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
          "${chainEventInEditMode?.event.title}_${chainEventInEditMode?.index.toString()}",
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: addStartDateController,
                  onTap: () async {
                    chainStartDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(3000),
                    );
                    if (chainStartDate == null) {
                      return;
                    }
                    addStartDateController.text =
                        DateFormat.yMEd().format(chainStartDate!);
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
                  },
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
                  onTap: () async {
                    TimeOfDay initTime = TimeOfDay.fromDateTime(
                        DateTime.now().add(const Duration(minutes: 1)));
                    TimeOfDay? selectedTime = await showTimePicker(
                          context: context,
                          initialTime: initTime,
                        ) ??
                        initTime;

                    chainStartDate ??= DateTime.now();
                    addStartDateController.text =
                        DateFormat.yMEd().format(chainStartDate!);
                    chainStartTime = DateTime(
                      chainStartDate!.year,
                      chainStartDate!.month,
                      chainStartDate!.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    addStartTimeController.text =
                        DateFormat.jms().format(chainStartTime!);
                  },
                  keyboardType: TextInputType.none,
                  textInputAction: TextInputAction.none,
                  textAlign: TextAlign.center,
                  //initialValue: tempChain.at?.toIso8601String() ?? "",
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    label: const Text("Chain Execution Time"),
                    hintText: eventDurationHour.toString().padLeft(2, '0'),
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
                  },
                  items:
                      repeatTypes.map<DropdownMenuItem<String>>((String value) {
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
                        "Repeat ends",
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: repeatOccur[0],
                  onChanged: (String? value) async {
                    if (value == null || value == "") {
                      return;
                    }
                    repeatOccur.remove(value);
                    repeatOccur.insert(0, value);
                    if (value == repeatOccurNever) {
                      tempChain.repeatCount = repeatTypeDefaultCount;
                    }
                  },
                  items:
                      repeatOccur.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      alignment: Alignment.center,
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (repeatOccur[0] == repeatOccurAfter)
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: tempChain.repeatCount.toString(),
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
                          return "Give valid integer value";
                        }
                      } catch (e) {
                        return "Insert valid integer value";
                      }
                    },
                    onSaved: (newValue) => tempChain.repeatCount =
                        newValue == null
                            ? repeatTypeDefaultCount
                            : int.parse(newValue),
                  ),
                ),
              if (repeatOccur[0] == repeatOccurAfter)
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
            style: Theme.of(context).textTheme.headline6,
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
                FocusScope.of(context).requestFocus(addEventFocus),
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
                    child: ChainEventsWidget(
                      tempChain: tempChain,
                      editEvent: editEvent,
                      undoEdit: undoEdit,
                    ),
                  ),
                ),
                chainInputForm,
                if (addingDurationToEvent) duraitonInputForm,
                if (addingScheduleToChain) startDateTimeInputForm,
                AppBar(
                  automaticallyImplyLeading: !updatingSystemWaitEventInDB &&
                      !addingScheduleToChain &&
                      MediaQuery.of(context).viewInsets.bottom == 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (!updatingSystemWaitEventInDB &&
                          !addingScheduleToChain)
                        Expanded(
                          child: TextField(
                            cursorColor: Theme.of(context).shadowColor,
                            focusNode: addEventFocus,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              label: const Text(
                                'Add Task or Event',
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              prefixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    addingDurationToEvent =
                                        !addingDurationToEvent;
                                  });
                                },
                                icon: Icon(
                                  Icons.timelapse,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ),
                            controller: addEventController,
                            onSubmitted: (_) {
                              onSubmitText();
                            },
                          ),
                        ),
                      if (updatingSystemWaitEventInDB || addingScheduleToChain)
                        IconButton(
                          onPressed: () {
                            undoEdit(chainEventInEditMode!);
                          },
                          icon: const Icon(Icons.cancel_outlined),
                        ),
                      IconButton(
                        onPressed: onSubmitText,
                        icon: chainEventInEditMode != null
                            ? const Icon(Icons.done_outline)
                            : updatingSystemWaitEventInDB
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
