import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
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

  Future<void> editActivity(ChainActivity chainActivity) async {}
  Future<void> undoEdit(ChainActivity chainActivity) async {}

  @override
  void dispose() {
    super.dispose();
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
    final durationInputForm = Form(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
                    onPressed: () {},
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
                    validator: (value) {
                      return null;
                    },
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
                    validator: (value) {
                      return null;
                    },
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
                    validator: (value) {
                      return null;
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: IconButton(
                    onPressed: () {},
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
                          onPressed: () {},
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
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      onPressed: () {},
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
                  return;
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

    return IgnorePointer(
      ignoring: true,
      child: Scaffold(
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
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      key: KeyHelper.addChainSaveAndExitKey,
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back),
                    ),
                    if (!updatingSystemWaitActivityInDB &&
                        tempChain.title.isNotEmpty)
                      Expanded(
                        key: KeyHelper.addChainAddActivityBarKey,
                        child: TextField(
                          cursorColor: Theme.of(context).shadowColor,
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
                              icon: Icon(
                                addingDurationToActivity
                                    ? Icons.settings_suggest_outlined
                                    : Icons.settings_suggest,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {},
                        ),
                      ),
                    if (updatingSystemWaitActivityInDB)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.cancel_outlined),
                      ),
                    if (tempChain.at != null)
                      TextButton(
                        onPressed: () {},
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
                        onPressed: () {},
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
    );
  }
}
