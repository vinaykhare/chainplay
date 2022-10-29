import 'package:flutter/material.dart';
import 'package:schedule_it/models/activity.dart';

class AddActivityScreen extends StatefulWidget {
  static String routename = "/add_activity";
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  GlobalKey<FormState> activityFormKey = GlobalKey<FormState>();
  Activity tempActivity = Activity(
    title: "",
    activityDuration: const Duration(seconds: 0),
    nextActivityAfter: const Duration(seconds: 0),
  );
  String pageTitle = "Add Activity";
  String buttonText = "Add Activity";
  bool pageInit = true;
  String activityTitleOnPageLoad = "";

  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0,
      restDurationAfterHour = 0,
      restDurationAfterMinute = 0,
      restDurationAfterSecond = 0;

  Future<void> addActivity() async {
    bool? isValidActivity = activityFormKey.currentState?.validate();
    if (isValidActivity == null || !isValidActivity) {
      return;
    }
    activityFormKey.currentState?.save();

    Navigator.of(context).pop(
      Activity(
        title: tempActivity.title,
        activityDuration: Duration(
          hours: activityDurationHour,
          minutes: activityDurationMinute,
          seconds: activityDurationSecond,
        ),
        nextActivityAfter: Duration(
          hours: restDurationAfterHour,
          minutes: restDurationAfterMinute,
          seconds: restDurationAfterSecond,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempActivity = ModalRoute.of(context)?.settings.arguments as Activity;
        pageTitle = "Edit Schedule";
        buttonText = "Update Activity";
        activityTitleOnPageLoad = tempActivity.title;

        Duration activityDuration = tempActivity.activityDuration;
        Duration restDuration = tempActivity.nextActivityAfter;

        activityDurationHour = activityDuration.inHours;
        activityDurationMinute =
            activityDuration.inMinutes - (activityDurationHour * 60);
        if (activityDurationMinute == 0) {
          activityDurationSecond =
              activityDuration.inSeconds - (activityDurationHour * 3600);
        } else {
          activityDurationSecond =
              activityDuration.inSeconds - (activityDurationMinute * 60);
        }

        restDurationAfterHour = restDuration.inHours;
        restDurationAfterMinute =
            restDuration.inMinutes - (restDurationAfterHour * 60);
        if (restDurationAfterMinute == 0) {
          restDurationAfterSecond =
              restDuration.inSeconds - (restDurationAfterHour * 3600);
        } else {
          restDurationAfterSecond =
              restDuration.inSeconds - (restDurationAfterMinute * 60);
        }
      }
      pageInit = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
        ),
      ),
      body: Form(
        key: activityFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Add Activity"),
            TextFormField(
              initialValue: tempActivity.title,
              decoration: const InputDecoration(
                label: Text("Activity Title"),
              ),
              onSaved: (newValue) => tempActivity.title = newValue ?? "",
            ),
            const SizedBox(
              height: 10,
            ),
            // Slider(
            //   value: actDurHour,
            //   onChanged: (newVal) => setState(
            //     () {
            //       actDurHour = newVal;
            //     },
            //   ),
            //   min: 0,
            //   max: 23,
            //   divisions: 5,
            //   label: actDurHour.round().toString().padLeft(2, '0'),
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Expanded(
                  child: Text(
                    "Activity Duration:",
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        activityDurationHour.toString().padLeft(2, '0'),
                    decoration: const InputDecoration(
                      label: Text("HH"),
                    ),
                    onSaved: (newValue) => activityDurationHour =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        activityDurationMinute.toString().padLeft(2, '0'),
                    onSaved: (newValue) => activityDurationMinute =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                    decoration: const InputDecoration(label: Text("MM")),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        activityDurationSecond.toString().padLeft(2, '0'),
                    onSaved: (newValue) => activityDurationSecond =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                    decoration: const InputDecoration(label: Text("SS")),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Expanded(
                  child: Text(
                    "Next Activity Duration:",
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        restDurationAfterHour.toString().padLeft(2, '0'),
                    onSaved: (newValue) => restDurationAfterHour =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                    decoration: const InputDecoration(label: Text("HH")),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        restDurationAfterMinute.toString().padLeft(2, '0'),
                    onSaved: (newValue) => restDurationAfterMinute =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                    decoration: const InputDecoration(label: Text("MM")),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        restDurationAfterSecond.toString().padLeft(2, '0'),
                    onSaved: (newValue) => restDurationAfterSecond =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                    decoration: const InputDecoration(label: Text("SS")),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: addActivity,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
