import 'dart:io';

import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
import 'package:duration_picker/duration_picker.dart';

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
      formImageUrlErrorString = "",
      formActivityTitleErrorString = "",
      chainNameOnPageLoad = "";

  bool showSaveAndExit = false,
      addingDurationToActivity = false,
      updatingSystemWaitActivityInDB = false,
      // scrollAtTop = false,
      pageInit = true;

  int activityDurationHour = 0,
      activityDurationMinute = 0,
      activityDurationSecond = 0;

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
    setState(() {
      errorString = "";
    });
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    bool nameExist = await chainList.nameExistInDB(tempChain.title);
    if (tempChain.title.length > 35) {
      setState(() {
        errorString =
            "Length of Chain name ${tempChain.title} is too long. It should not be more than 35 letters long.";
      });
      return false;
    }
    if (nameExist) {
      setState(() {
        errorString = "Chain name ${tempChain.title} is taken.";
      });
      return false;
    }
    return true;
  }

  Future<void> saveAndExit() async {
    NavigatorState nav = Navigator.of(context);
    for (ChainActivity chainActivity in tempChain.activities) {
      undoEdit(chainActivity);
    }
    bool result = await validateForm(context);
    if (result) {
      if (nav.canPop()) {
        nav.pop();
      } else {
        nav.pushReplacementNamed(ChainListScreen.routename);
      }
    }
  }

  Future<bool> validateForm(BuildContext context,
      [bool existingScreen = true]) async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    FocusScopeNode fsn = FocusScope.of(context);
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
    fsn.requestFocus(addActivityFocus);
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

  Future<bool> validURL(String path) async {
    if (path == "") {
      return true;
    } else if (path.startsWith("http")) {
      try {
        Uri uri = Uri.parse(path); // Try to parse the path as a URI
        var response = await http.get(uri); // Make HTTP request [1, 10]

        if (response.statusCode == 200 &&
            response.headers['content-type']!.startsWith('image/')) {
          return true; // Valid image URL [1, 10]
        }
        return true;
      } catch (e) {
        return false;
      }
    } else if (path.startsWith("/")) {
      return File(path).existsSync();
    }
    return false;
  }

  void onSubmitText() async {
    FocusScopeNode focusScope = FocusScope.of(context);
    setState(() {
      errorString = "";
      formImageUrlErrorString = "";
      formActivityTitleErrorString = "";
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

    if (addActivityController.text.isEmpty &&
        (activityImageController.text.isNotEmpty ||
            activityDurationHour > 0 ||
            activityDurationMinute > 0 ||
            activityDurationSecond > 0)) {
      setState(() {
        formActivityTitleErrorString = "Add Chain Activity Name";
      });
      return;
    }

    if (addActivityController.text.isEmpty) {
      return;
    }

    if (addActivityController.text.length > 35) {
      setState(() {
        formActivityTitleErrorString =
            "Length of Acitivity Name is too long. It should not be more than 35 letters long.";
      });
      return;
    }

    if (activityImageController.text.isNotEmpty) {
      bool isValidURL = await validURL(activityImageController.text);
      if (!isValidURL) {
        setState(() {
          formImageUrlErrorString = "Invald Image URL";
        });
        return;
      }
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

      focusScope.requestFocus(addActivityFocus);
    }

    addActivityController.clear();
    activityImageController.clear();

    durationHourController.clear();
    durationMinuteController.clear();
    durationSecondController.clear();

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

  Future<void> undoEdit(ChainActivity chainActivity) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    addActivityController.clear();
    activityImageController.clear();
    durationHourController.clear();
    durationMinuteController.clear();
    durationSecondController.clear();

    chainActivityInEditMode = chainActivity;
    chainActivityInEditMode!.edit = false;
    addingDurationToActivity = false;

    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    //await chainList.resetChain(tempChain);
    await chainList.updateChainActivityByActivityId(
        tempChain, chainActivityInEditMode!);

    setState(() {
      chainActivityInEditMode = null;
      // addingDurationToActivity = false;
      activityDurationHour = 0;
      activityDurationMinute = 0;
      activityDurationSecond = 0;
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

    double appWidth = MediaQuery.of(context).size.width;

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
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Text(
                "Specifications of Activity",
                style: Theme.of(context).textTheme.titleSmall,
                //textAlign: TextAlign.left,
              ),
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
                              setState(() {
                                formImageUrlErrorString = "";
                              });
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
                  if (formImageUrlErrorString == "" &&
                      activityImageController.text != "" &&
                      (activityImageController.text.startsWith("/") ||
                          activityImageController.text.startsWith("http")))
                    Container(
                      height: appWidth * 0.135,
                      width: appWidth * 0.135,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: activityImageController.text == ""
                          ? Image.asset(
                              assetMap['noImagePlaceholder']!,
                              fit: BoxFit.fitHeight,
                            )
                          : activityImageController.text.startsWith("http")
                              ? FadeInImage.assetNetwork(
                                  placeholder: assetMap["noImagePlaceholder"]!,
                                  image: activityImageController.text,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                          Image.asset(
                                    assetMap['noImagePlaceholder']!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.file(
                                  File(activityImageController.text),
                                  fit: BoxFit.cover,
                                ),
                    ),
                  Expanded(
                    child: activityImageController.text.startsWith("/")
                        ? IgnorePointer(
                            ignoring: true,
                            child: TextFormField(
                              //readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                label: Center(
                                  child: Text(
                                    formImageUrlErrorString == ""
                                        ? "Local Image"
                                        : formImageUrlErrorString,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  //color: Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: "https://",
                                alignLabelWithHint: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                              ),
                            ),
                          )
                        : TextFormField(
                            key: ValueKey(
                              "${chainActivityInEditMode?.activity.title.toString()}_${chainActivityInEditMode?.index.toString()}_image",
                            ),
                            keyboardType: TextInputType.url,
                            textAlign: TextAlign.center,
                            controller: activityImageController,
                            // onSaved: (_) => chainActivityInEditMode!
                            //         .activity.specification![activitySpecImagePath] =
                            //     activityImageController.text,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: Text(
                                "HTTP URL to an Image or a GIF",
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              hintText: "https://",
                              alignLabelWithHint: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                            ),
                            validator: (imagePath) {
                              try {
                                if (imagePath != null && imagePath != "") {
                                  if (imagePath.startsWith("http")) {
                                    Uri.parse(imagePath);
                                  } else {
                                    return File(imagePath).existsSync()
                                        ? null
                                        : "Invalid File Path";
                                  }
                                }
                              } catch (exception) {
                                return "Invalid URL";
                              }
                              return null;
                            },
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      onPressed: () {
                        activityImageController.clear();
                        setState(() {
                          formImageUrlErrorString = "";
                        });
                      },
                      icon: Semantics(
                        label:
                            "Clear the selected image or its url in add activity form.",
                        child: const Icon(
                          Icons.clear_all,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (formImageUrlErrorString != "")
              Semantics(
                label: "Form Image URL Error Message",
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    formImageUrlErrorString,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final resultingDuration = await showDurationPicker(
                        context: context,
                        initialTime: const Duration(seconds: 30),
                        baseUnit: BaseUnit.second,
                        upperBound: const Duration(seconds: 60),
                        lowerBound: const Duration(seconds: 10),
                      );
                      if (resultingDuration != null) {
                        durationHourController.text =
                            resultingDuration.inHours.toString();
                        durationMinuteController.text =
                            (resultingDuration.inMinutes -
                                    resultingDuration.inHours * 60)
                                .toString();
                        durationSecondController.text =
                            (resultingDuration.inSeconds -
                                    (resultingDuration.inMinutes * 60))
                                .toString();
                      }
                    },
                    icon: Icon(
                      Icons.watch_later,
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
                      label: Text(
                        "Hour",
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
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
                      label: Text(
                        "Minute",
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
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
                      label: Text(
                        "Second",
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
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
                    icon: Semantics(
                      label: "Clear the duration field in add activity form.",
                      child: const Icon(
                        Icons.clear_all,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (formActivityTitleErrorString != "")
              Semantics(
                label: "Form Image URL Error Message",
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    formActivityTitleErrorString,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final chainInputForm = Column(
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
                // validator: (value) {
                //   if ((value == null || value == "") &&
                //       tempChain.activities.isNotEmpty) {
                //     return "\tInsert a valid Chain Name";
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  tempChain.title = value ?? "";
                },
                onFieldSubmitted: (value) {
                  validateForm(context, false);
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
                label: "Chain Error Message",
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
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Semantics(
                    label: "Save and Go back previous screen",
                    child: IconButton(
                      onPressed: saveAndExit,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  if (!updatingSystemWaitActivityInDB &&
                      tempChain.title.isNotEmpty)
                    Expanded(
                      child: TextField(
                        cursorColor: Theme.of(context).shadowColor,
                        focusNode: addActivityFocus,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          label: Text(
                            'Chain Activity Name',
                            style: TextStyle(
                              color: Theme.of(context).disabledColor,
                            ),
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
                            icon: Semantics(
                              label:
                                  "Toggle to show the Duration and Image field to be added along with this activity.",
                              child: Icon(
                                addingDurationToActivity
                                    ? Icons.settings_suggest_outlined
                                    : Icons.settings_suggest,
                                color: Theme.of(context).iconTheme.color,
                              ),
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
                  //if (tempChain.title.isNotEmpty)
                  IconButton(
                    onPressed: tempChain.title.isNotEmpty
                        ? onSubmitText
                        : () {
                            validateForm(context, false);
                          },
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
