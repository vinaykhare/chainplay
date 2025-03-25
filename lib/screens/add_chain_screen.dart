import 'dart:io';

import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/screens/pixabay_selection_screen.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pixabay_picker/model/pixabay_media.dart';
import 'package:pixabay_picker/pixabay_api.dart';
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
      // formImageUrlErrorString = "",
      activityFormErrorString = "",
      chainNameOnPageLoad = "";

  bool showSaveAndExit = false,
      addingDurationToActivity = false,
      addingImageToActivity = false,
      updatingSystemWaitActivityInDB = false,
      // scrollAtTop = false,
      pageInit = true,
      processingRequest = false,
      showSubmitActivityButton = true;

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
  late ScaffoldMessengerState scms;

  @override
  void dispose() {
    addActivityFocus.dispose();
    addActivityController.dispose();
    super.dispose();
  }

  Future<bool> isNameValid() async {
    setState(() {
      errorString = "";
      processingRequest = true;
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
    setState(() {
      processingRequest = false;
    });
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
    setState(() {
      processingRequest = true;
    });
    if (chainFormKey.currentState == null) {
      setState(() {
        processingRequest = false;
      });
      return true;
    }
    bool valid = chainFormKey.currentState!.validate();

    chainFormKey.currentState?.save();

    bool validName = await isNameValid();
    if (!valid || !validName) {
      setState(() {
        processingRequest = false;
      });
      return false;
    }

    if (tempChain.activities.isNotEmpty && tempChain.title == "") {
      setState(() {
        errorString =
            "Give a valid name to this Chain!\n OR\n Remove all Activites to delete the Chain.";
        processingRequest = false;
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
    setState(() {
      processingRequest = false;
    });
    return true;
  }

  Future<void> addActivity(ChainActivity newActivity) async {
    setState(() {
      processingRequest = true;
    });
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    ChainActivity restChainActivity = ChainActivity(
      activity: restActivity,
    );
    bool validName = await isNameValid();

    if (!(validName)) {
      setState(() {
        processingRequest = false;
      });
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
    setState(() {
      processingRequest = false;
    });
  }

  //chainActivityInEditMode should not be null before calling this function.
  Future<void> updateActivity(ChainActivity newActivity) async {
    setState(() {
      processingRequest = true;
    });
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    bool validName = await isNameValid();

    if (!(validName)) {
      setState(() {
        processingRequest = true;
      });
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
      processingRequest = false;
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

  Future<void> updateDurationForAllSystemWaitActivity() async {
    setState(() {
      errorString = "";
      activityFormErrorString = "";
    });

    String? validHour = validateHour(durationHourController.text);
    String? validMinute = validateMinuteOrSecond(durationMinuteController.text);
    String? validSecond = validateMinuteOrSecond(durationSecondController.text);

    if (validHour != null) {
      setState(() {
        activityFormErrorString = "Hours should be in the range of $validHour";
      });
      return;
    }

    if (validMinute != null) {
      setState(() {
        activityFormErrorString =
            "Minutes should be in the range of $validMinute";
      });
      return;
    }
    if (validSecond != null) {
      setState(() {
        activityFormErrorString =
            "Seconds should be in the range of $validSecond";
      });
      return;
    }

    activityDurationHour = durationHourController.text == ""
        ? 0
        : int.parse(durationHourController.text);
    activityDurationMinute = durationMinuteController.text == ""
        ? 0
        : int.parse(durationMinuteController.text);
    activityDurationSecond = durationSecondController.text == ""
        ? 0
        : int.parse(durationSecondController.text);
    setState(() {
      processingRequest = true;
    });
    for (var chainActivity in tempChain.activities) {
      if (chainActivity.activity.type == systemWaitActivityInDB) {
        chainActivityInEditMode = chainActivity;
        chainActivityInEditMode!.edit = false;
        chainActivityInEditMode!.activityDuration = Duration(
          hours: activityDurationHour,
          minutes: activityDurationMinute,
          seconds: activityDurationSecond,
        );

        await updateActivity(chainActivityInEditMode!);
      }
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
      addingImageToActivity = false;
      processingRequest = false;
    });
  }

  void onSubmitText() async {
    FocusScopeNode focusScope = FocusScope.of(context);
    setState(() {
      errorString = "";
      activityFormErrorString = "";
      processingRequest = true;
    });

    bool validChainForm = chainFormKey.currentState!.validate();
    bool validDurationForm = durationFormKey.currentState?.validate() ?? true;
    bool validStartDateTimeForm =
        startDateTimeInputKey.currentState?.validate() ?? true;
    if (!validChainForm || !validDurationForm || !validStartDateTimeForm) {
      setState(() {
        processingRequest = false;
      });
      return;
    }

    chainFormKey.currentState?.save();
    durationFormKey.currentState?.save();
    startDateTimeInputKey.currentState?.save();
    if (tempChain.title == "") {
      setState(() {
        errorString =
            "Please insert the Chain name before adding activity to it.";
        processingRequest = false;
      });
      return;
    }

    if (addActivityController.text.isEmpty &&
        (activityImageController.text.isNotEmpty ||
            activityDurationHour > 0 ||
            activityDurationMinute > 0 ||
            activityDurationSecond > 0)) {
      setState(() {
        activityFormErrorString = "Add Chain Activity Name";
        processingRequest = false;
      });
      return;
    }

    if (addActivityController.text.isEmpty) {
      setState(() {
        processingRequest = false;
      });
      return;
    }

    if (addActivityController.text.length > 35) {
      setState(() {
        activityFormErrorString =
            "Length of Acitivity Name is too long. It should not be more than 35 letters long.";
        processingRequest = false;
      });
      return;
    }

    if (activityImageController.text.isNotEmpty) {
      bool isValidURL = await validURL(activityImageController.text);
      if (!isValidURL) {
        setState(() {
          activityFormErrorString = "Invalid Path or URL";
          processingRequest = false;
        });
        return;
      }
    }

    String? validHour = validateHour(durationHourController.text);
    String? validMinute = validateMinuteOrSecond(durationMinuteController.text);
    String? validSecond = validateMinuteOrSecond(durationSecondController.text);

    if (validHour != null) {
      setState(() {
        activityFormErrorString = "Hours should be in the range of $validHour";
        processingRequest = false;
      });
      return;
    }

    if (validMinute != null) {
      setState(() {
        activityFormErrorString =
            "Minutes should be in the range of $validMinute";
        processingRequest = false;
      });
      return;
    }
    if (validSecond != null) {
      setState(() {
        activityFormErrorString =
            "Seconds should be in the range of $validSecond";
        processingRequest = false;
      });
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
      addingImageToActivity = false;
      processingRequest = false;
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
    setState(() {
      processingRequest = true;
    });
    FocusScopeNode focusScope = FocusScope.of(context);
    addActivityController.clear();
    activityImageController.clear();
    durationHourController.clear();
    durationMinuteController.clear();
    durationSecondController.clear();

    chainActivityInEditMode = chainActivity;
    chainActivityInEditMode!.edit = false;
    addingDurationToActivity = false;
    addingImageToActivity = false;

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
      processingRequest = false;
    });
    focusScope.unfocus();
  }

  Future<void> editActivity(
    ChainActivity chainActivity, [
    bool editDuration = true,
    bool editImage = true,
  ]) async {
    FocusScopeNode focusScope = FocusScope.of(context);
    setState(() {
      processingRequest = true;
    });

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

    setState(() {
      addingDurationToActivity = editDuration;
      addingImageToActivity = editImage;
      activityDurationHour = chainActivityDuration.inHours;
      activityDurationMinute =
          chainActivityDuration.inMinutes - (activityDurationHour * 60);
      activityDurationSecond = chainActivityDuration.inSeconds -
          (activityDurationHour * 3600) -
          (activityDurationMinute * 60);
      activityImageController.text = chainActivityInEditMode!
              .activity.specification?[activitySpecImagePath] ??
          "";

      if (chainActivity.activity.type == systemStartActivityInDB) {
        chainStartDate = tempChain.at;
        chainStartTime = tempChain.at;
        addingDurationToActivity = false;
        addingImageToActivity = false;
      }

      if (chainActivity.activity.type == systemWaitActivityInDB) {
        addingImageToActivity = false;
      }
      processingRequest = false;
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

    addActivityController.text = chainActivity.activity.title;
    if (!updatingSystemWaitActivityInDB &&
        !addingDurationToActivity &&
        !addingImageToActivity) {
      focusScope.requestFocus(addActivityFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    //ChainList chainList = Provider.of<ChainList>(context, listen: false);
    if (pageInit) {
      scms = ScaffoldMessenger.of(context);
      if (ModalRoute.of(context)?.settings.arguments != null) {
        tempChain = ModalRoute.of(context)?.settings.arguments as Chain;
        pageTitle = tempChain.title;
        chainNameOnPageLoad = tempChain.title;
        //tempChain.loadActivities();
      } else {
        showSaveAndExit = true;
      }
      addActivityController.addListener(() {
        setState(() {
          if (addActivityController.text.isNotEmpty) {
            showSubmitActivityButton = true;
          } else {
            showSubmitActivityButton = false;
          }
        });
      });
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

    var imageInputForm = Row(
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
                  String imagePath = "";
                  String imageSelectionError = "";
                  NavigatorState nav = Navigator.of(context);

                  setState(() {
                    processingRequest = true;
                  });
                  bool? dialogResponse = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          "Choose an Image Source",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(true),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: appWidth * 0.20,
                                      child: Image(
                                        image: AssetImage(
                                            assetMap['pixabaylogo']!),
                                        fit: BoxFit.fill,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                        width: 50,
                                      ),
                                    ),
                                    Text(
                                      "PixaBay\nRecommendation",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inverseSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Theme.of(context).secondaryHeaderColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => Navigator.of(context).pop(false),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: appWidth * 0.20,
                                      child: Icon(
                                        Icons.sd_storage_outlined,
                                        size: 45,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ),
                                    Text(
                                      "Pick from\nLocal Storage",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inverseSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  try {
                    if (dialogResponse == true) {
                      PixabayMediaProvider api = PixabayMediaProvider(
                        apiKey: pixaBayApiKey,
                        language: "en",
                      );
                      PixabayResponse? result =
                          await api.requestImagesWithKeyword(
                              keyword: addActivityController.text,
                              resultsPerPage: 100);

                      if (result != null &&
                          result.hits != null &&
                          result.hits!.isNotEmpty) {
                        List<String?> pixabayLinks = result.hits!.map((hit) {
                          return hit.getDownloadLink();
                        }).toList();

                        int? chosenPictureIndex = await nav.pushNamed(
                          PixabaySelectionScreen.routename,
                          arguments: {
                            "activityTitle": addActivityController.text,
                            "pixabayLinks": pixabayLinks,
                          },
                        ) as int?;
                        if (chosenPictureIndex != null) {
                          imagePath = pixabayLinks[chosenPictureIndex] ?? "";
                        } else {
                          imagePath = "";
                        }
                      } else {
                        // User cancelled the picker
                        imageSelectionError =
                            "Pixabay is unable to get images matching the Chain Activity Name.";
                      }
                      setState(() {
                        processingRequest = false;
                      });
                    }
                    // XFile? pickedImage = await ImagePicker()
                    //     .pickImage(source: ImageSource.gallery);
                    // if (pickedImage != null) {
                    //   // activityImageController.text = pickedImage.path;
                    //   setState(() {
                    //     localImagePath = pickedImage.path;
                    //   });
                    // }
                    else if (dialogResponse == false) {
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
                        imagePath = result.files.single.path!;
                      } else {
                        // User cancelled the picker
                      }
                    }
                  } catch (e) {
                    imageSelectionError = e.toString();
                  }

                  if (imageSelectionError != "") {
                    scms.showSnackBar(
                      SnackBar(
                        content: Text(
                          //e.toString(),
                          imageSelectionError,
                          textAlign: TextAlign.center,
                        ),
                        duration: const Duration(seconds: 10),
                        action: SnackBarAction(
                          //textColor: Colors.white,
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );
                  } else {
                    activityImageController.text = imagePath;
                  }
                  setState(() {
                    activityFormErrorString = "";
                    processingRequest = false;
                  });
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
        if (activityFormErrorString == "" &&
            activityImageController.text != "" &&
            activityImageController.text.startsWith("http"))
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
                        imageErrorBuilder: (context, error, stackTrace) =>
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
              ? Container(
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
                              fit: BoxFit.contain,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                assetMap['noImagePlaceholder']!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.file(
                              File(activityImageController.text),
                              fit: BoxFit.contain,
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
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  onFieldSubmitted: (imagePath) async {
                    bool valid = await validURL(imagePath);
                    if (!valid) {
                      activityImageController.text = "";
                      activityFormErrorString = "Invalid Path or URL";
                    }
                    // if (imagePath.startsWith("/") &&
                    //     !File(imagePath).existsSync()) {
                    //   activityImageController.text = "";
                    //   formImageUrlErrorString = "Invalid Local Path";
                    // }
                    // if (imagePath.startsWith("http")) {
                    //   try {
                    //     Uri.parse(imagePath);
                    //   } catch (e) {
                    //     activityImageController.text = "";
                    //     formImageUrlErrorString = "Invalid Http path";
                    //   }
                    // }
                  },
                  // validator: (imagePath) {
                  //   String? validationError;
                  //   try {
                  //     if (imagePath != null && imagePath != "") {
                  //       if (imagePath.startsWith("http")) {
                  //         Uri.parse(imagePath);
                  //       } else if (!File(imagePath).existsSync()) {
                  //         activityImageController.text = "";
                  //         validationError = "Invalid File Path";
                  //       }
                  //     }
                  //     return validationError;
                  //   } catch (exception) {
                  //     return "Invalid URL";
                  //   }
                  // },
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
                activityFormErrorString = "";
              });
            },
            icon: Semantics(
              label:
                  "Clear the selected image or its url in add activity form.",
              child: Icon(
                Icons.clear_all,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
    var durationInputForm = Row(
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
                durationMinuteController.text = (resultingDuration.inMinutes -
                        resultingDuration.inHours * 60)
                    .toString();
                durationSecondController.text = (resultingDuration.inSeconds -
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
                newValue != "" && newValue != null ? int.parse(newValue) : 0,
            onFieldSubmitted: (value) {
              String? valResult = validateHour(value);
              if (valResult != null) {
                activityFormErrorString =
                    "Hours should be in the range of $valResult";
              }
            },
            // validator: (value) => validateHour(value),
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
                newValue != "" && newValue != null ? int.parse(newValue) : 0,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: Text(
                "Minute",
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              ),
              hintText: activityDurationMinute.toString().padLeft(2, '0'),
            ),
            onFieldSubmitted: (value) {
              String? valResult = validateMinuteOrSecond(value);
              if (valResult != null) {
                activityFormErrorString =
                    "Minutes should be in the range of $valResult";
              }
            },
            // validator: (value) => validateMinuteOrSecond(value),
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
                newValue != "" && newValue != null ? int.parse(newValue) : 0,
            onChanged: (value) {},
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              label: Text(
                "Second",
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              ),
              hintText: activityDurationSecond.toString().padLeft(2, '0'),
              alignLabelWithHint: true,
            ),
            onFieldSubmitted: (value) {
              String? valResult = validateMinuteOrSecond(value);
              if (valResult != null) {
                activityFormErrorString =
                    "Seconds should be in the range of $valResult";
              }
            },
            // validator: (value) => validateMinuteOrSecond(value),
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
                activityFormErrorString = "";
              });
            },
            icon: Semantics(
              label: "Clear the duration field in add activity form.",
              child: Icon(
                Icons.clear_all,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
    final activitySpecificationForm = Form(
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
                (chainActivityInEditMode?.activity.type !=
                            systemStartActivityInDB &&
                        chainActivityInEditMode?.activity.type !=
                            systemWaitActivityInDB)
                    ? "Specifications of Activity"
                    : "Add Rest Duration",
                style: Theme.of(context).textTheme.titleSmall,
                //textAlign: TextAlign.left,
              ),
            ),
            if (activityFormErrorString != "")
              Semantics(
                label: "Activity Form Error Message",
                child: Text(
                  activityFormErrorString,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: Theme.of(context).colorScheme.error),
                  // style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            // else
            //   SizedBox(
            //     height: 16,
            //   ),
            if (addingImageToActivity) imageInputForm,
            if (addingDurationToActivity) durationInputForm,
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
        // child: Stack(
        //   children: [
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
                child: Semantics(
                  label: "Editable Chain of Activities",
                  child: ChainActivitiesWidget(
                    tempChain: tempChain,
                    editActivity: editActivity,
                    undoEdit: undoEdit,
                  ),
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
            if ((addingDurationToActivity || addingImageToActivity) &&
                tempChain.title.isNotEmpty)
              activitySpecificationForm,
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: "Save and Go back to previous screen",
                    child: SizedBox(
                      // width: appWidth * 0.21,
                      child: IconButton(
                        onPressed: saveAndExit,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      // child: InkWell(
                      //   onTap: saveAndExit,
                      //   child: Column(
                      //     children: [
                      //       const Icon(Icons.arrow_back),
                      //       Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(horizontal: 5),
                      //         child: const Text("Save & Exit"),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ),
                  ),
                  if (!updatingSystemWaitActivityInDB &&
                      tempChain.title.isNotEmpty)
                    Expanded(
                      child: TextField(
                        cursorColor: Theme.of(context).shadowColor,
                        focusNode: addActivityFocus,
                        decoration: InputDecoration(
                          //floatingLabelBehavior: FloatingLabelBehavior.never,
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
                                addingImageToActivity = !addingImageToActivity;
                              });
                            },
                            icon: Semantics(
                              label:
                                  "Toggle to show the Duration and Image field to be added along with this activity.",
                              child: Icon(
                                addingDurationToActivity ||
                                        addingImageToActivity
                                    ? Icons.settings_suggest_outlined
                                    : Icons.settings_suggest,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                          ),
                        ),
                        controller: addActivityController,
                        onSubmitted: (_) {
                          if (!processingRequest) {
                            onSubmitText();
                          }
                        },
                      ),
                    ),
                  // if (tempChain.at != null)
                  //   TextButton(
                  //     onPressed: () {
                  //       undoEdit(chainActivityInEditMode!);
                  //       tempChain.at = null;
                  //       tempChain.repeatType = repeatTypeDoesNotRepeat;
                  //       tempChain.repeatCount = repeatTypeDefaultCount;
                  //     },
                  //     child: CircleAvatar(
                  //       radius: 50,
                  //       child: Text(
                  //         "Remove\nAlarm",
                  //         style: Theme.of(context).textTheme.labelSmall,
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   ),
                  // if (chainActivityInEditMode == null ||
                  //     chainActivityInEditMode!.activity.type !=
                  //         systemWaitActivityInDB)

                  if (chainActivityInEditMode != null)
                    InkWell(
                      onTap: () {
                        undoEdit(chainActivityInEditMode!);
                        // tempChain.at = null;
                        // tempChain.repeatType = repeatTypeDoesNotRepeat;
                        // tempChain.repeatCount = repeatTypeDefaultCount;
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15 // appWidth * 0.04,
                            ),
                        child: Column(
                          children: [
                            const Icon(Icons.cancel_outlined),
                            const Text("Discard"),
                          ],
                        ),
                      ),
                    ),
                  if (updatingSystemWaitActivityInDB)
                    InkWell(
                      onTap: updateDurationForAllSystemWaitActivity,
                      child: Column(
                        children: [
                          if (processingRequest)
                            CircularProgressIndicator(
                              color: Colors.black,
                            )
                          else
                            const Icon(Icons.done_all),
                          if (updatingSystemWaitActivityInDB)
                            const Text("Between All"),
                        ],
                      ),
                    ),
                  if (showSubmitActivityButton)
                    Column(
                      children: [
                        InkWell(
                          onTap: processingRequest
                              ? null
                              : tempChain.title.isNotEmpty
                                  ? onSubmitText
                                  : () {
                                      validateForm(context, false);
                                    },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15 // appWidth * 0.04,
                                ),
                            child: Column(
                              children: [
                                if (processingRequest)
                                  CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                else
                                  chainActivityInEditMode != null ||
                                          updatingSystemWaitActivityInDB
                                      ? const Icon(Icons.done_outline)
                                      : const Icon(Icons.add_task_outlined),
                                if (updatingSystemWaitActivityInDB)
                                  const Text("Just here"),
                              ],
                            ),
                          ),
                        ),
                        // IconButton(
                        //   onPressed:
                        //       tempChain.title.isNotEmpty && !processingRequest
                        //           ? onSubmitText
                        //           : () {
                        //               validateForm(context, false);
                        //             },
                        //   icon: chainActivityInEditMode != null ||
                        //           updatingSystemWaitActivityInDB
                        //       ? const Icon(Icons.done_outline)
                        //       : const Icon(Icons.add_task_outlined),
                        // ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        // Expanded(
        //   child: Positioned(
        //     bottom: 50,
        //     child: AnimatedContainer(
        //       width: ((addingDurationToActivity || addingImageToActivity) &&
        //               tempChain.title.isNotEmpty)
        //           ? appWidth
        //           : 0,
        //       duration: Duration(milliseconds: 500),
        //       curve: Curves.easeOut,
        //       color: Colors.black,
        //       child: ((addingDurationToActivity || addingImageToActivity) &&
        //               tempChain.title.isNotEmpty)
        //           ? activitySpecificationForm
        //           : null,
        //     ),
        //   ),
        // ),
        // ],
        // ),
      ),
    );
  }
}
