import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/activity.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_activity_screen.dart';
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

  final TextEditingController scheduleAtController = TextEditingController();

  DateTime formDateTime = DateTime.now();
  String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> scheduleFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> activityFormKey = GlobalKey<FormState>();

  bool pageInit = true;
  String scheduleNameOnPageLoad = "";

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

  Future<void> addSchedule() async {
    scheduleFormKey.currentState?.validate();
    scheduleFormKey.currentState?.save();
    if (tempSchedule.activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Add Activity to Create Schedule!"),
        ),
      );
      return;
    }
    Provider.of<ScheduleList>(context, listen: false)
        .addSchedule(tempSchedule, scheduleNameOnPageLoad);
    Navigator.of(context).pop();
  }

  Future<void> addActivity(Activity newActivity) async {
    // bool? isValidActivity = activityFormKey.currentState?.validate();
    // if (isValidActivity == null || !isValidActivity) {
    //   return;
    // }
    // activityFormKey.currentState?.save();

    setState(
      () {
        tempSchedule.activities.add(
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
      title: Text(pageTitle),
      actions: [
        ElevatedButton.icon(
          onPressed: addSchedule,
          icon: const Icon(Icons.add_alarm),
          label: const Text("Save"),
        ),
      ],
    );

    double appHeight = MediaQuery.of(context).size.height -
        appBarWidget.preferredSize.height -
        MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      appBar: appBarWidget,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: scheduleFormKey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Unique Schedule Name"),
                      ),
                      initialValue: tempSchedule.name,
                      onSaved: (newValue) => tempSchedule.name = newValue ??
                          "Schedule ${DateFormat.yMEd().add_jms().format(DateTime.now())}",
                    ),
                    const Divider(
                      thickness: 0,
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

                    const Text("Start"),
                    SizedBox(
                      height: appHeight * 0.5,
                      child: ActivitiesTimeline(
                        tempSchedule: tempSchedule,
                        removeActivity: removeActivity,
                        replaceActivity: replaceActivity,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          Activity tempAcitivity = await Navigator.of(context)
              .pushNamed(AddActivityScreen.routename) as Activity;
          addActivity(tempAcitivity);
          /** Start of Show Dialog **/
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return AlertDialog(
          //       content: Form(
          //         key: activityFormKey,
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             const Text("Add Activity"),
          //             TextFormField(
          //               decoration: const InputDecoration(
          //                 label: Text("Activity Title"),
          //               ),
          //               onSaved: (newValue) => activityTitle = newValue ?? "",
          //             ),
          //             const SizedBox(
          //               height: 10,
          //             ),
          //             // Slider(
          //             //   value: actDurHour,
          //             //   onChanged: (newVal) => setState(
          //             //     () {
          //             //       actDurHour = newVal;
          //             //     },
          //             //   ),
          //             //   min: 0,
          //             //   max: 23,
          //             //   divisions: 5,
          //             //   label: actDurHour.round().toString().padLeft(2, '0'),
          //             // ),

          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 const Expanded(
          //                   child: Text(
          //                     "Activity Duration:",
          //                     textAlign: TextAlign.center,
          //                   ),
          //                 ),
          //                 const SizedBox(
          //                   width: 30,
          //                 ),
          //                 Expanded(
          //                   child: TextFormField(
          //                     //controller: activityDurationHourController,
          //                     decoration: const InputDecoration(
          //                       label: Text("HH"),
          //                     ),
          //                     onSaved: (newValue) => activityDurationHour =
          //                         newValue != "" && newValue != null
          //                             ? int.parse(newValue)
          //                             : 0,
          //                   ),
          //                 ),
          //                 Expanded(
          //                   child: TextFormField(
          //                     onSaved: (newValue) => activityDurationMinute =
          //                         newValue != "" && newValue != null
          //                             ? int.parse(newValue)
          //                             : 0,
          //                     decoration:
          //                         const InputDecoration(label: Text("MM")),
          //                   ),
          //                 ),
          //                 Expanded(
          //                   child: TextFormField(
          //                     onSaved: (newValue) => activityDurationSecond =
          //                         newValue != "" && newValue != null
          //                             ? int.parse(newValue)
          //                             : 0,
          //                     decoration:
          //                         const InputDecoration(label: Text("SS")),
          //                   ),
          //                 ),
          //               ],
          //             ),

          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 const Expanded(
          //                   child: Text(
          //                     "Next Activity Duration:",
          //                     textAlign: TextAlign.center,
          //                   ),
          //                 ),
          //                 const SizedBox(
          //                   width: 30,
          //                 ),
          //                 Expanded(
          //                   child: TextFormField(
          //                     onSaved: (newValue) => restDurationAfterHour =
          //                         newValue != "" && newValue != null
          //                             ? int.parse(newValue)
          //                             : 0,
          //                     decoration:
          //                         const InputDecoration(label: Text("HH")),
          //                   ),
          //                 ),
          //                 Expanded(
          //                   child: TextFormField(
          //                     onSaved: (newValue) => restDurationAfterMinute =
          //                         newValue != "" && newValue != null
          //                             ? int.parse(newValue)
          //                             : 0,
          //                     decoration:
          //                         const InputDecoration(label: Text("MM")),
          //                   ),
          //                 ),
          //                 Expanded(
          //                   child: TextFormField(
          //                     onSaved: (newValue) => restDurationAfterSecond =
          //                         newValue != "" && newValue != null
          //                             ? int.parse(newValue)
          //                             : 0,
          //                     decoration:
          //                         const InputDecoration(label: Text("SS")),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //       actions: [
          //         TextButton(
          //           onPressed: () => Navigator.of(context).pop(),
          //           child: const Text("Cancel"),
          //         ),
          //         TextButton(
          //           onPressed: () {
          //             addActivity();
          //             Navigator.of(context).pop();
          //           },
          //           child: const Text("Add Activity"),
          //         ),
          //       ],
          //     );
          //   },
          // );
          /** End of Show Dialog **/
        },
        label: const Text("Add Activity"),
        icon: const Icon(
          Icons.add_task_rounded,
        ),
      ),
    );
  }
}
