import 'package:flutter/material.dart';
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
  DateTime? chainStartTime;

  String pageTitle = "Add Chain",
      eventTitle = "",
      errorString = "",
      chainNameOnPageLoad = "";

  bool addingDurationToEvent = false,
      addingChainToChain = false,
      updatingSystemWaitEventInDB = false,
      pageInit = true;

  int eventDurationHour = 0, eventDurationMinute = 0, eventDurationSecond = 0;

  final TextEditingController addEventController = TextEditingController();
  final TextEditingController addStartTimeController = TextEditingController();

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
      Chain chainInExecution = await chainList.moveChainToHistory(tempChain);
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
    addStartTimeController.clear();
    setState(() {
      eventDurationHour = 0;
      eventDurationMinute = 0;
      eventDurationSecond = 0;
      addingDurationToEvent = false;
      addingChainToChain = false;
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
    chainEventInEditMode = chainEvent;
    chainEventInEditMode!.edit = false;

    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    await chainList.resetChain(tempChain);
    await chainList.updateChainEventByEventId(tempChain, chainEventInEditMode!);

    setState(() {
      chainEventInEditMode = null;
      addingDurationToEvent = false;
      addingChainToChain = false;
      eventDurationHour = 0;
      eventDurationMinute = 0;
      updatingSystemWaitEventInDB = false;
    });
    focusScope.unfocus();
  }

  void editEvent(ChainEvent chainEvent) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    await chainList.resetChain(tempChain);
    chainEventInEditMode = chainEvent;

    chainEventInEditMode!.edit = true;

    await chainList.updateChainEventByEventId(
      tempChain,
      chainEventInEditMode!,
    );

    updatingSystemWaitEventInDB = chainEvent.event.type == systemWaitEventInDB;

    Duration chainEventDuration = chainEvent.eventDuration;

    if (chainEvent.event.type == systemStartEventInDB) {
      setState(() {
        addingChainToChain = true;
        addingDurationToEvent = false;
        chainStartTime = tempChain.at;
        addStartTimeController.text = chainStartTime != null
            ? DateFormat.yMEd().add_jms().format(chainStartTime!)
            : "";
      });
    } else {
      setState(() {
        addingChainToChain = false;
        addingDurationToEvent = true;
        eventDurationHour = chainEventDuration.inHours;
        eventDurationMinute =
            chainEventDuration.inMinutes - (eventDurationHour * 60);
        eventDurationSecond = chainEventDuration.inSeconds -
            (eventDurationHour * 3600) -
            (eventDurationMinute * 60);
      });
    }
    addEventController.text = chainEvent.event.title;
    if (!updatingSystemWaitEventInDB && !addingChainToChain) {
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
      child: Row(
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
                  newValue != "" && newValue != null ? int.parse(newValue) : 0,
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
                  newValue != "" && newValue != null ? int.parse(newValue) : 0,
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
                  newValue != "" && newValue != null ? int.parse(newValue) : 0,
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
    );

    final startDateTimeInputForm = Form(
      key: startDateTimeInputKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: ValueKey(
            "${chainEventInEditMode?.event.title}_${chainEventInEditMode?.index.toString()}",
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
            TimeOfDay initTime = TimeOfDay.fromDateTime(
                DateTime.now().add(const Duration(minutes: 1)));
            // TimeOfDay initTime = TimeOfDay(
            //   hour: TimeOfDay.now().hour,
            //   minute: TimeOfDay.now().minute + 5,
            // );
            TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: initTime,
                ) ??
                initTime;

            chainStartTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            addStartTimeController.text =
                DateFormat.yMEd().add_jms().format(chainStartTime!);
          },
          keyboardType: TextInputType.none,
          textInputAction: TextInputAction.none,
          textAlign: TextAlign.center,
          //initialValue: tempChain.at?.toIso8601String() ?? "",
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: const Text("Shedule Start Time"),
            hintText: eventDurationHour.toString().padLeft(2, '0'),
            suffixIcon: const Icon(Icons.calendar_month),
          ),
          validator: (value) {
            if (chainStartTime != null &&
                chainStartTime!.isAfter(DateTime.now())) {
              return null;
            } else {
              return "Select Date Time in Future";
            }
          },
          onSaved: (newValue) {
            tempChain.at = chainStartTime;
          },
        ),
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
                if (addingChainToChain) startDateTimeInputForm,
                AppBar(
                  automaticallyImplyLeading: !updatingSystemWaitEventInDB &&
                      !addingChainToChain &&
                      MediaQuery.of(context).viewInsets.bottom == 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (!updatingSystemWaitEventInDB && !addingChainToChain)
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
                      if (updatingSystemWaitEventInDB || addingChainToChain)
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
