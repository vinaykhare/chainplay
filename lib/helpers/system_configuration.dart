//SQF Lite initialization SQLs

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/models/chain_list.dart';
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
    "imageAsset": assetMap["cat_intro"]!,
    "imageNetwork":
        "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/cat_intro.png?raw=true",
    "title": "Thanks for choosing CAT",
    "speech":
        "Thanks for choosing CAT. CAT is a tool to Chain the activities with the help of Timers.",
  },
  // {
  //   "imageAsset": assetMap["chains"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/chains.jpeg?raw=true",
  //   "title": "Sample Chains",
  //   "speech":
  //       "Chains looks like this. CAT comes with these sample chains to start with. You can play it, stop it, make it favorite, remove it by swiping it right and also share and receive it in file format.",
  // },
  // {
  //   "imageAsset": assetMap["individual_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/individual_chain.jpeg?raw=true",
  //   "title": "Chain with Timer Activities",
  //   "speech":
  //       "This is how a Chain looks when we open it, just by tapping on it."
  // },
  // {
  //   "imageAsset": assetMap["play_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/play_chain.gif?raw=true",
  //   "title": "Play Chain",
  //   "speech":
  //       "Chain plays interactively. Timer keeps ticking every second, but you can pause it too. Activities without timer can be completed by pressing done button on screen.",
  // },
  // {
  //   "imageAsset": assetMap["share_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/share_chain.gif?raw=true",
  //   "title": "Share the Chain.",
  //   "speech": "You can share the Chain as a file using your favorite medium.",
  // },
  // {
  //   "imageAsset": assetMap["receive_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/receive_chain.gif?raw=true",
  //   "title": "Receive the Chain.",
  //   "speech": "And you can receive the Chain in a file.",
  // },
  // {
  //   "imageAsset": assetMap["upload_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/upload_chain.gif?raw=true",
  //   "title": "Upload the Chain File.",
  //   "speech":
  //       "CAT also allows to recieve the Chain by uploading the file using Upload Button on Home Screen.",
  // },
  // {
  //   "imageAsset": assetMap["create_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/create_chain.jpeg?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "CAT provides a Simple User Interface to Create your own Chain of Timer Activities.",
  // },
  // {
  //   "imageAsset": assetMap["create_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/create_chain-1.gif?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "It starts with Create chain form where we need to give a unique name to our chain first and then we can add activities to it.",
  // },
  // {
  //   "imageAsset": assetMap["create_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/create_chain-2.gif?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "Chain keeps forming as we add activities to it using form at the bottom of screen. We can add activity with any name, and set timer to it. If we are not setting any timer, then it becomes a manual activity, which will complete on pressing done.",
  // },
  // {
  //   "imageAsset": assetMap["create_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/create_chain-3.gif?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "We can add a timer to take rest between the two activities in a chain too.",
  // },
  // {
  //   "imageAsset": assetMap["create_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/create_chain-4.gif?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "While creating the chain, we can edit the already added activity or remove it too.",
  // },
  // {
  //   "imageAsset": assetMap["create_chain"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/create_chain-5.gif?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "Rearranging the activities after adding it to the chain is also possible.",
  // },
  // {
  //   "imageAsset": assetMap["settings"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/gif/app_settings.gif?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "App Settings can be accessed from app drawer at the bottom left. You can switch to Dark Theme here.",
  // },
  // {
  //   "imageAsset": assetMap["appdrawer"]!,
  //   "imageNetwork":
  //       "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/appdrawer.jpeg?raw=true",
  //   "title": "Create the Chain",
  //   "speech":
  //       "You can play this CAT's introduction again from the app drawer. Just tap on What is Cat?",
  // },
  {
    "imageAsset": assetMap["go_home"]!,
    "imageNetwork":
        "https://github.com/vinaykhare/cat_help_content/blob/main/help_images/go_home.png?raw=true",
    "title": "Now just Explore CAT",
    "speech": "Now just explore the CAT yourself. I believe that it will help.",
  },
];

List<Map<String, dynamic>> getTutorialItemsByType(
    BuildContext context, String tutorialType, ChainList chainList) {
  List<Map<String, dynamic>> tutorialItemType;

  switch (tutorialType) {
    case showHomeScreenTutorialKey:
      tutorialItemType = [
        {
          "title": "CAT Header",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "CAT App",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Header of CAT App contains its Logo with Couple of most frequently used buttons.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.homeCatKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title": "One of the Buttons is to Create the Chain",
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
          "title": "And another button to create a chain by uploading a file",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Upload Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This app allows us to Share the Chain or download the Chain in file format.\n This button allows us to upload that file and create the Chain as per file configuration.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.uploadChainButtonKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "This section lists all the chains present in your app. CAT App comes with few sample chains which are also listed here. We will take example of one of the sample chains to brief you more about the Chains.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "All the Chains",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Tap here and start typing the name of chain or name of activity in the chain.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chainListKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "This section is just kept for your help to understand the set actions that you can perform on a chain.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Sumary of Chain Contorls",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "This section is just kept for your help to understand the set actions that you can perform on a chain.",
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
              "You can hide it or keep it as your taste by clicking this expand shrink button",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Hide Sumary of Chain Contorls",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Click this button to shrink this banner or expand it back, as you like.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.minmaxChainControlSummaryKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.bottom,
        },
        {
          "title":
              "You can also search the chains by tapping here, with the content like Chain Title or Title of Activities in it.",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Search Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Tap here and start typing the name of chain or name of activity in the chain.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.searchChainKey,
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
        {
          "title":
              "Now Lets take this Sample Workout Chain as an example to understand, what is chain?",
          "widgetToShow": ListView(
            shrinkWrap: true,
            children: [
              Text(
                "Sample Workout Chain",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "Lets take this Sample Workout Chain as an example to understand, what is chain?",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          "globalKey": KeyHelper.chainListKey,
          "focusAlign": Alignment.bottomCenter,
          "contentAlign": ContentAlign.top,
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
          "focusAlign": Alignment.topCenter,
          "contentAlign": ContentAlign.top,
        },
      ];
      break;
    case showAddChainScreenTutorialKey:
      tutorialItemType = [];

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
