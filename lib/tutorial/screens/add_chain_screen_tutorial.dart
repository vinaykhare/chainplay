import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/tutorial/screens/chain_list_screen_tutorial.dart';
import 'package:chain_activities/widgets/help_clip_horizontal.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

class AddChainScreenTutorial extends StatefulWidget {
  static String routename = "/add_chains_tutorial";

  const AddChainScreenTutorial({super.key});

  @override
  State<AddChainScreenTutorial> createState() => _AddChainScreenTutorialState();
}

class _AddChainScreenTutorialState extends State<AddChainScreenTutorial> {
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
      addingDurationToActivity = true,
      updatingSystemWaitActivityInDB = false,
      // scrollAtTop = false,
      pageInit = true;

  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0;
  final ScrollController scrollController = ScrollController();
  final TextEditingController addActivityController = TextEditingController();
  final TextEditingController activityImageController = TextEditingController();

  final TextEditingController durationHourController = TextEditingController();
  final TextEditingController durationMinuteController =
      TextEditingController();
  final TextEditingController durationSecondController =
      TextEditingController();
  //String durHour = "", durMin = "", durSec = "";
  GlobalKey<FormState> chainFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> durationFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> startDateTimeInputKey = GlobalKey<FormState>();
  FocusNode addActivityFocus = FocusNode();

  @override
  void dispose() {
    addActivityFocus.dispose();
    addActivityController.dispose();
    super.dispose();
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
    for (ChainActivity chainActivity in tempChain.activities) {
      undoEdit(chainActivity);
    }
    bool result = await validateForm();
    if (result) {
      navigatorState.pushReplacementNamed(ChainListScreenTutorial.routename);
    }
  }

  Future<bool> validateForm([bool existingScreen = true]) async {
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

    if (tempChain.activities.isEmpty &&
        tempChain.title != "" &&
        existingScreen) {
      // setState(() {
      //   errorString =
      //       "Add atleast one Timer Activity to this Chain.\n Or Remove the Chain Name and go back to Discard the Chain.";
      // });
      // return false;
      await chainList.removeChain(tempChain);
    }

    if (tempChain.activities.isEmpty && tempChain.title == "") {
      tempChain.title =
          chainNameOnPageLoad != "" ? chainNameOnPageLoad : tempChain.title;
      chainList.removeChain(tempChain);
    }

    if (tempChain.activities.isNotEmpty &&
        tempChain.title != chainNameOnPageLoad) {
      await chainList.renameChain(
        chainNameOnPageLoad,
        tempChain.title,
      );
      tempChain.lastUpdatedAt = DateTime.now();
      await chainList.updateChain(tempChain);
    }

    if (!(tempChain.title == "" &&
        tempChain.activities.isEmpty &&
        chainNameOnPageLoad == "")) {
      tempChain.edit = false;
      await chainList.updateChain(tempChain, false);
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

    tempChain.edit = true;

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
    tempChain.lastUpdatedAt = DateTime.now();
    tempChain.edit = true;
    await chainList.updateChain(tempChain);
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
      //if (activityImageController.text.isNotEmpty) {
      chainActivityInEditMode!.activity.specification = {
        activitySpecImagePath: activityImageController.text,
      };
      //}

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
    activityImageController.clear();
    setState(() {
      activityDurationHour = 0;
      activityDurationMinute = 0;
      activityDurationSecond = 0;
      //addingDurationToActivity = false;
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

  Future<void> undoEdit(ChainActivity chainActivity) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    addActivityController.clear();
    activityImageController.clear();
    chainActivityInEditMode = chainActivity;
    chainActivityInEditMode!.edit = false;

    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    //await chainList.resetChain(tempChain);
    await chainList.updateChainActivityByActivityId(
        tempChain, chainActivityInEditMode!);

    setState(() {
      chainActivityInEditMode = null;
      addingDurationToActivity = false;
      activityDurationHour = 0;
      activityDurationMinute = 0;
      updatingSystemWaitActivityInDB = false;
    });
    focusScope.unfocus();
  }

  Future<void> editActivity(ChainActivity chainActivity) async {
    //FocusScopeNode focusScope = FocusScope.of(context);

    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    chainActivityInEditMode = chainActivity;
    await chainList.updatChainActivityByChainName(tempChain);
    chainActivityInEditMode!.edit = true;
    // await chainList.resetChain(tempChain);
    await chainList.updateChainActivityByActivityId(
      tempChain,
      chainActivityInEditMode!,
    );

    updatingSystemWaitActivityInDB =
        chainActivityInEditMode!.activity.type == systemWaitActivityInDB;

    Duration chainActivityDuration = chainActivityInEditMode!.activityDuration;

    if (chainActivity.activity.type == systemStartActivityInDB) {
      setState(() {
        addingDurationToActivity = false;
        chainStartDate = tempChain.at;
        chainStartTime = tempChain.at;
      });
    } else {
      setState(() {
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
      durationHourController.text = activityDurationHour == 0
          ? ""
          : activityDurationHour.toString().padLeft(2, '0');
      durationMinuteController.text = activityDurationMinute == 0
          ? ""
          : activityDurationMinute.toString().padLeft(2, '0');
      durationSecondController.text = activityDurationSecond == 0
          ? ""
          : activityDurationSecond.toString().padLeft(2, '0');
    }
    addActivityController.text = chainActivity.activity.title;
    // if (!updatingSystemWaitActivityInDB && !addingScheduleToChain) {
    //   focusScope.requestFocus(addActivityFocus);
    // }
  }

  @override
  Widget build(BuildContext context) {
    //ChainList chainList = Provider.of<ChainList>(context, listen: false);
    if (pageInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempChain = ModalRoute.of(context)?.settings.arguments as Chain;
        pageTitle = tempChain.title;
        chainNameOnPageLoad = tempChain.title;
        //tempChain.loadActivities();
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

    final durationInputForm = Form(
      key: durationFormKey,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
        child: Column(
          key: KeyHelper.addChainAddActivitySpecificationBarKey,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Text(
                "Chain Activity Specifications",
                style: Theme.of(context).textTheme.titleSmall,
                //textAlign: TextAlign.left,
              ),
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.watch_later,
                      color: Theme.of(context).shadowColor,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: ValueKey(
                      "${chainActivityInEditMode?.activity.title}_${chainActivityInEditMode?.index.toString()}_hours",
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.none,
                    textAlign: TextAlign.center,
                    // initialValue: activityDurationHour == 0
                    //     ? null
                    //     : activityDurationHour.toString().padLeft(2, '0'),
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
                    controller: durationHourController,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: ValueKey(
                      "${chainActivityInEditMode?.activity.title.toString()}_${chainActivityInEditMode?.index.toString()}_minutes",
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    // initialValue: activityDurationMinute == 0
                    //     ? null
                    //     : activityDurationMinute.toString().padLeft(2, '0'),
                    onSaved: (newValue) => activityDurationMinute =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: const Text(
                        "Minute",
                      ),
                      hintText:
                          activityDurationMinute.toString().padLeft(2, '0'),
                    ),
                    validator: (value) => validateMinuteOrSecond(value),
                    controller: durationMinuteController,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: ValueKey(
                      "${chainActivityInEditMode?.activity.title.toString()}_${chainActivityInEditMode?.index.toString()}_seconds",
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    // initialValue: activityDurationSecond == 0
                    //     ? null
                    //     : activityDurationSecond.toString().padLeft(2, '0'),
                    onSaved: (newValue) => activityDurationSecond =
                        newValue != "" && newValue != null
                            ? int.parse(newValue)
                            : 0,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      label: const Text("Second"),
                      hintText:
                          activityDurationSecond.toString().padLeft(2, '0'),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => validateMinuteOrSecond(value),
                    controller: durationSecondController,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        durationHourController.clear();
                        durationMinuteController.clear();
                        durationSecondController.clear();
                        activityDurationHour = 0;
                        activityDurationMinute = 0;
                        activityDurationSecond = 0;
                      });
                    },
                    icon: const Icon(
                      Icons.clear_all,
                    ),
                  ),
                ),
              ],
            ),
            if (chainActivityInEditMode?.activity.type !=
                    systemStartActivityInDB &&
                chainActivityInEditMode?.activity.type !=
                    systemWaitActivityInDB)
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.photo,
                          ),
                          onPressed: () async {
                            // XFile? pickedImage = await ImagePicker()
                            //     .pickImage(source: ImageSource.gallery);
                            // if (pickedImage != null) {
                            //   // activityImageController.text = pickedImage.path;
                            //   setState(() {
                            //     localImagePath = pickedImage.path;
                            //   });
                            // }
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'jpg',
                                'jpeg',
                                'gif',
                                'png',
                                'webp',
                                'svg',
                                'jfif',
                                'pjpeg',
                                'pjp',
                                'apng',
                                'avif',
                                'bmp',
                                'tif',
                                'tiff',
                                'ico',
                                'cur'
                              ],
                            );
                            if (result != null) {
                              activityImageController.text =
                                  result.files.single.path!;
                              setState(() {});
                            } else {
                              // User cancelled the picker
                            }
                          },
                        ),
                      ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 10),
                      //   child: Text(
                      //     "Select Local",
                      //   ),
                      // ),
                    ],
                  ),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey(
                        "${chainActivityInEditMode?.activity.title.toString()}_${chainActivityInEditMode?.index.toString()}_image",
                      ),
                      keyboardType: TextInputType.url,
                      textAlign: TextAlign.center,
                      controller: activityImageController,
                      // onSaved: (_) => chainActivityInEditMode!
                      //         .activity.specification![activitySpecImagePath] =
                      //     activityImageController.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("Paste HTTP or Local Path or Image."),
                        hintText: "https://",
                        alignLabelWithHint: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      onPressed: () {
                        activityImageController.clear();
                      },
                      icon: const Icon(
                        Icons.clear_all,
                      ),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );

    final chainInputForm = Column(
      key: KeyHelper.addChainTitleKey,
      children: [
        Form(
          key: chainFormKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: tempChain.title == "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
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
                onFieldSubmitted: (value) {
                  validateForm(false);
                },
              ),
            ],
          ),
        ),
        if (tempChain.title.isEmpty ||
            tempChain.title == "" ||
            tempChain.activities.length == 1)
          const Icon(Icons.arrow_upward),
        if (tempChain.title.isEmpty || tempChain.title == "")
          const CircleAvatar(
            radius: 50,
            child: Text(
              "Insert a Unique Chain Name first & Submit",
              textAlign: TextAlign.center,
            ),
          )
        else if (tempChain.activities.length == 1)
          const CircleAvatar(
            radius: 50,
            child: Text(
              "You can modify this Alarm Title",
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );

    return Scaffold(
      //appBar: appBarWidget,
      body: SafeArea(
        child: Column(
          children: [
            Semantics(
              label: tempChain.title.isEmpty
                  ? "Chain Input Form"
                  : "Chain Input Form for : ${tempChain.title}",
              child: chainInputForm,
            ),
            if (errorString != "")
              Semantics(
                label: "Error Message",
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    errorString,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (errorString != "")
              Divider(
                thickness: 1,
                color: Theme.of(context).dividerTheme.color,
              ),
            Expanded(
              key: KeyHelper.addChainKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Semantics(
                      label: "Editable Chain of Activities",
                      child: ChainActivitiesWidget(
                        tempChain: tempChain,
                        editActivity: editActivity,
                        undoEdit: undoEdit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).cardColor,
              ),
              child: const ShowBannerAd(),
            ),
            if (addingDurationToActivity && tempChain.title.isNotEmpty)
              durationInputForm,
            if (tempChain.activities.length <= 1 &&
                tempChain.title.isNotEmpty &&
                !addingDurationToActivity)
              const HelpClipHorizontal(),
            AppBar(
              key: KeyHelper.addChainSaveAndExitKey,
              automaticallyImplyLeading: !updatingSystemWaitActivityInDB &&
                  MediaQuery.of(context).viewInsets.bottom == 0,
              title: Row(
                key: KeyHelper.addChainAddActivityBarKey,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (showSaveAndExit &&
                      (MediaQuery.of(context).viewInsets.bottom == 0 ||
                          tempChain.title.isEmpty ||
                          tempChain.title == ""))
                    IconButton(
                      onPressed: saveAndExit,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  if (!updatingSystemWaitActivityInDB &&
                      tempChain.title.isNotEmpty)
                    Expanded(
                      child: TextField(
                        cursorColor: Theme.of(context).shadowColor,
                        focusNode: addActivityFocus,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          label: const Text(
                            'Add Timer Activity to this Chain',
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
                              addingDurationToActivity
                                  ? Icons.settings_suggest_outlined
                                  : Icons.settings_suggest,
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
                  if (updatingSystemWaitActivityInDB)
                    IconButton(
                      onPressed: () {
                        undoEdit(chainActivityInEditMode!);
                        // tempChain.at = null;
                        // tempChain.repeatType = repeatTypeDoesNotRepeat;
                        // tempChain.repeatCount = repeatTypeDefaultCount;
                      },
                      icon: const Icon(Icons.cancel_outlined),
                    ),
                  if (tempChain.at != null)
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
                  if (tempChain.title.isNotEmpty)
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
    );
  }
}
