//SQF Lite initialization SQLs

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/cat_text_button.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const int sqfLiteDBVersion = 1;

const sqlInitScript = [
  '''CREATE TABLE activity (
      activityId TEXT PRIMARY KEY, 
      title TEXT, 
      specifications TEXT, 
      type INTEGER,
      createdAt INTEGER, 
      lastUpdatedAt INTEGER,
      edit INTEGER
    )
  ''',
  '''CREATE TABLE chain (
      title TEXT PRIMARY KEY,
      chainIndex INTEGER,
      createdAt INTEGER, 
      lastUpdatedAt INTEGER, 
      pinned INTEGER,
      startedAt INTEGER,
      pivotDate INTEGER,
      endedAt INTEGER,
      chainStatus INTEGER,
      notificationId TEXT,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      editChain INTEGER
    )
  ''',
  '''CREATE TABLE chain_execution (
      chainExecutionId TEXT PRIMARY KEY,
      title TEXT,
      startedAt INTEGER,
      pivotDate INTEGER,
      endedAt INTEGER,
      chainStatus INTEGER,
      notificationId TEXT,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title)
    )
  ''',
  '''CREATE TABLE chain_activity (
      title TEXT, 
      activityId TEXT,
      activityIndex INTEGER,
      activityDone INTEGER,
      isInterrupted INTEGER,
      notificationId TEXT,
      activityDuration INTEGER,
      startedAt INTEGER,
      activityDurationLeft INTEGER,
      endedAt INTEGER,
      editChainActivity INTEGER,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title),
      FOREIGN KEY (activityId)
        REFERENCES activity (activityId)
    )
  ''',
  '''CREATE TABLE chain_activity_execution (
      chainExecutionId TEXT,
      title TEXT, 
      activityId TEXT,
      activityIndex INTEGER,
      activityDone INTEGER,
      isInterrupted INTEGER,
      notificationId TEXT,
      activityDuration INTEGER,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      startedAt INTEGER,      
      activityDurationLeft INTEGER,
      endedAt INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title),
      FOREIGN KEY (activityId)
        REFERENCES activity (activityId),
      FOREIGN KEY (chainExecutionId)
        REFERENCES chain_execution (chainExecutionId)
    )
  ''',
  '''CREATE TABLE settings (
      key TEXT PRIMARY KEY, 
      value TEXT,
      type TEXT
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      '$darkThemeSettingKey',
      '$falseSettingValue',
      '$settingDataTypeBool'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      '$appSoundSettingKey',
      '$trueSettingValue',
      '$settingDataTypeBool'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      '$showHelpOnNextBootKey', 
      '$trueSettingValue',
      '$settingDataTypeHiddenBool'
    )
  ''',
];

// Constant Header Content

List<Map<String, String>> headerSlideContent = [
  {
    "imageAsset": assetMap["logoImage"]!,
    "imageNetwork": "",
    "title": "ChainPlay",
    "subtitle": "Chain the Activities and Play it",
    "speech":
        "Thanks for choosing Chain Play. Chain Play is a tool to Chain your activities and Play it. Lets undestand the major functions of Chain Play App with a quick tutorial. You have the option to skip this tutorial by pressing the Close button.",
  },
  // {
  //   "imageAsset": assetMap["chains"]!,
  //   "imageNetwork": "",
  //   "title": "CHAINS",
  //   "subtitle": "Runs in Background or Foreground",
  //   "speech":
  //       "Chain Play has multiple features to streamline your activities with chains.",
  // },
];

List<Map<String, dynamic>> getTutorialItemsByType(
    BuildContext context, String tutorialType, ChainList chainList) {
  List<Map<String, dynamic>> tutorialItemType;

  switch (tutorialType) {
    case showHelpOnNextBootKey:
      tutorialItemType = [
        {
          "title": "ChainPlay Header",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "ChainPlay Header",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This is the App's header with a Logo and Couple of Buttons to the right. Now press on the highlighted section over this and the following screens to move to the next slide of this tutorial.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.homeChainAndPlayKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title": "Press here to Create a New Chain of Activities",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Create Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This Button will take you to a form which will help you to create the Chain of Activities.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.createNewChainButtonKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "And press this one to create a new chain by uploading a file",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Upload Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This app allows us to Share the Chain or download the Chain in file format.\nThis button allows us to upload that file and create the Chain as per file configuration.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Image.asset(
                assetMap["chain_file_view"]!,
                fit: BoxFit.scaleDown,
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).viewPadding.top -
                        MediaQuery.of(context).viewPadding.bottom) *
                    0.50,
              ),
            ],
          ),
          "globalKey": KeyHelper.uploadChainButtonKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "This section lists all the chains present in your app. Chain Play App comes with few sample chains as listed here.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "All the Chains",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "List of all the chains present in your app. Chain Play comes with few sample chains as listed here. ",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chainListKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "We can have a situation where Chain was created but it is not present or listed here",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "All the Chains",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Cannot find your chain here?",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chainListKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": "Try refreshing the page by tapping over the app logo here.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "App Icon",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "App Icon is not just a logo but a button to refresh the home page of this app. Action fetches the chains, activities and app settings from this app's local database.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chainAndPlayTitle,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "This section is just kept for your help to understand the set of actions that you can perform for creating chains and playting with it.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Sumary of Chain Contorls",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This section is just kept for your help to understand the set of actions that you can perform for creating chains and playting with it.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chainControlSummaryKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "Bottom Bar of the App has a drawer at the left and a Search Text Box at the right. Pressing the App Drawer will open a Side Menu bar with all options like What is Chain Play which will Run this tutorial again, App Settings where you can switch to Dark Theme etcitra.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Bottom App Bar",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Bottom Bar of the App has a drawer at the left and a Search Text Box at the right.\n",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                "Pressing the App Drawer will open a Side Menu bar with all options like What is Chain Play which will Run this tutorial again, App Settings where you can switch to Dark Theme etc.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Image.asset(
                assetMap["app_drawer"]!,
                fit: BoxFit.scaleDown,
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).viewPadding.top -
                        MediaQuery.of(context).viewPadding.bottom) *
                    0.50,
              ),
            ],
          ),
          "globalKey": KeyHelper.chianListScreenAppBarkey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "You can also search the chains by tapping here, with the content like Chain Title or Title of Activities in it.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Search Chains",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "You can also search the chains by tapping here, with the content like Chain Title or Title of Activities in it.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chianListSearchkey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "We have also provided a button to quickly filter the chains.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Filter Chains",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "When number of chains are high, and we are struggling to find our favorite chains or running chains then these filters can help.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chainFiltersKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title": idToStartViewChain,
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Sample Workout Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Lets take this Sample Workout Chain as an example to understand a Chain and its features.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.sampleWorkoutChainListItemKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "This is how a Chain looks when you open it by tapping any chain on the home screen.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Sample Workout Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This screen has several options like we can play the chain, delete the chain, share or download the chain. And you can edit the chain too.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.viewChainKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "This section has series of buttons to take actions on this chain.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Chain Actions",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Series of buttons to take actions on this chain like Play Chain, Check its execution history, mark it favorite, share or download it in file format and delete this chain.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.viewChainOptionsKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "This bottom bar contains the title of the Chain at the Center, a button to go back to home screen at the left and a button to Edit this chain at the right.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Bottom Bar of Chain View Screen",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This bottom bar contains the title of the Chain at the Center, a button to go back to home screen at the left and a button to Edit this chain at the right.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.viewChainBottomBarKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": idToStartAddChain,
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Edit this Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                idToStartAddChain,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.viewChainEditButtonKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "This screen helps you to edit the chain. This screen also loads up when we choose to Create the Chain from Home screen.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Create or Edit Chain Screen",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This screen helps you to edit the chain. This screen also loads up when we choose to Create the Chain from Home screen.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.addChainKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title": "Here we have the title of chain which we can edit.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Chain Title",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "We can see or edit the chain title here.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.addChainTitleKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "Here we insert the name of activity to be added to the chain.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Add activity to Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Following form is used to add the activity to this chain or edit the existing activity in this chain.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.addChainAddActivityBarKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "Before submitting the activty, we can add duration to it, or an image to the activity.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Add Specifications to Activity",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "We can add the duration or an image to this activity. If we will not give the duration or image then this will become a Manual Activity with a default image.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.addChainAddActivitySpecificationBarKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": idToGoBackToViewChain,
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Save and Exit",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                idToGoBackToViewChain,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.addChainSaveAndExitKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": idToPlayChain,
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Play Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "We can play the chain by pressing this button. This button is present on home screen on the individual chain tile too.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.viewChainPlayChainKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "Chain Plays interactively activity by activity. Go back to pause the activity and explore chain execution status screen.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Playing Chain Activity",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Chain Plays interactively activity by activity.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playWaitKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": idToPauseTheChain,
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Pause or Resume the Chain Activity",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                idToPauseTheChain,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playWaitPlayPauseKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "Timer keeps ticking for the activity with Timer duration here. If the activity does not have timer then we get an option to press Done and complete the activty.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Acitivty Timer or Button to complete the Activty",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This section of screen shows the timer running in reverse. Activity will auto complete on completion of this Timer. For the Activities without Duration, we get the option to mark the activity as done here.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playWaitTimerKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "This button helps you to force complete the current activity and move to the next activity.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Go to next Activity of this Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This button helps you to force complete the current activity and move to the next activity.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playWaitForwardKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": idToGoToChainExecutionStatusScreen,
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Pause Chain and Go to Chain Execution Status screen.",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                idToGoToChainExecutionStatusScreen,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playWaitBackwardKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": "This screen shows the Execution status of the chain.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Chain Activity Execution",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This screen shows the Execution status of the chain.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playChainKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "This section displays the relevant buttons to take action for running the chain. Button to resume the chain in background shall be displayed if the Current Activity is timer activity and it is paused. Button to refresh the page shall be displayed if the chain is running in background. And a button to go to the Interactive View to play the chain shall be displayed if neither the chain is running in backgroud nor it can be run.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Relevant Actions on Current Activity",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This section displays the relevant buttons to take action for running the chain.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              CatTextButton(
                buttonLabel: "Play the Chain, in Background",
                buttonAction: () {},
                buttonIcon: Icons.play_circle,
              ),
              const Text(
                "Button to resume the chain in background shall be displayed if the Current Activity is timer activity and it is paused",
              ),
              CatTextButton(
                buttonLabel: "Refresh, for the latest status",
                buttonAction: () {},
                buttonIcon: Icons.refresh_outlined,
              ),
              const Text(
                "Button to refresh the page shall be displayed if the chain is running in background.",
              ),
              CatTextButton(
                buttonLabel: "Play the Chain, Interactively",
                buttonAction: () {},
                buttonIcon: Icons.arrow_forward_outlined,
              ),
              const Text(
                "Button to go to the Interactive View to play the chain shall be displayed if neither the chain is running in backgroud nor it can be run.",
              ),
            ],
          ),
          "globalKey": KeyHelper.playChainRunInBackgroundKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": "We can use this option to stop the Chain Execution.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Stop this Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "We can use this option to stop the Chain Execution. Schedule notifications (if any) will also be cancelled on stopping the Chain Execution.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playChainStopChainKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "Press the forward button to go back to Chain Activity Execution screen, where we can resume the Chain Activity Interactively. If the chain is running in background, and refresh button is also visible on the page then you will get the option to force complete the activity running in background and enter the interactive view of chain.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Open the Current Activity",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Press the forward button to go back to Chain Activity Execution screen, where we can resume the Chain Activity Interactively.\nIf the chain is running in background, and refresh button is also visible on the page then you will get the option to force complete the activity running in background and enter the interactive view of chain.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playChainForwardButtonKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title": idToComeBackToHome,
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "End of Tutorial | Go back to Home",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                idToComeBackToHome,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.playChainBackwardButtonKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
      ];
      break;

    default:
      tutorialItemType = [
        {
          "title": "Tutorial Not defined",
          "widgetToShow": Text(
            "Tutorial Not defined",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          "globalKey": KeyHelper.chainListKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
      ];
  }
  return tutorialItemType;
}
