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
    activityId: "",
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
        activityId: tempActivity.activityId,
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

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempActivity = ModalRoute.of(context)?.settings.arguments as Activity;
        pageTitle = "Edit Activity";
        buttonText = "Update Activity";
        activityTitleOnPageLoad = tempActivity.title;

        Duration activityDuration = tempActivity.activityDuration;
        Duration restDuration = tempActivity.nextActivityAfter;

        activityDurationHour = activityDuration.inHours;
        activityDurationMinute =
            activityDuration.inMinutes - (activityDurationHour * 60);
        activityDurationSecond = activityDuration.inSeconds -
            (activityDurationHour * 3600) -
            (activityDurationMinute * 60);

        restDurationAfterHour = restDuration.inHours;
        restDurationAfterMinute =
            restDuration.inMinutes - (restDurationAfterHour * 60);
        restDurationAfterSecond = restDuration.inSeconds -
            (restDurationAfterHour * 3600) -
            (restDurationAfterMinute * 60);
      }
      pageInit = false;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          pageTitle,
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: activityFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      initialValue: tempActivity.title,
                      decoration: const InputDecoration(
                        label: Text(
                          "Activity Title",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onSaved: (newValue) =>
                          tempActivity.title = newValue ?? "",
                      validator: (value) =>
                          value == null || value == "" ? "Title Missing" : null,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Activity Duration",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            initialValue: activityDurationHour == 0
                                ? null
                                : activityDurationHour
                                    .toString()
                                    .padLeft(2, '0'),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: const Text("Hour"),
                              hintText: activityDurationHour
                                  .toString()
                                  .padLeft(2, '0'),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Rest Duration after Activity",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            initialValue: restDurationAfterHour == 0
                                ? null
                                : restDurationAfterHour
                                    .toString()
                                    .padLeft(2, '0'),
                            onSaved: (newValue) => restDurationAfterHour =
                                newValue != "" && newValue != null
                                    ? int.parse(newValue)
                                    : 0,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: const Text("Hour"),
                              hintText: restDurationAfterHour
                                  .toString()
                                  .padLeft(2, '0'),
                            ),
                            validator: (value) => validateHour(value),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            initialValue: restDurationAfterMinute == 0
                                ? null
                                : restDurationAfterMinute
                                    .toString()
                                    .padLeft(2, '0'),
                            onSaved: (newValue) => restDurationAfterMinute =
                                newValue != "" && newValue != null
                                    ? int.parse(newValue)
                                    : 0,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: const Text("Minute"),
                              hintText: restDurationAfterMinute
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
                            initialValue: restDurationAfterSecond == 0
                                ? null
                                : restDurationAfterSecond
                                    .toString()
                                    .padLeft(2, '0'),
                            onSaved: (newValue) => restDurationAfterSecond =
                                newValue != "" && newValue != null
                                    ? int.parse(newValue)
                                    : 0,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: const Text("Second"),
                              hintText: restDurationAfterSecond
                                  .toString()
                                  .padLeft(2, '0'),
                            ),
                            validator: (value) => validateMinuteOrSecond(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Divider(
                      color: Colors.black,
                    ),
                    ElevatedButton(
                      onPressed: addActivity,
                      child: Text(buttonText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
