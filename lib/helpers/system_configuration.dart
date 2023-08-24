//SQF Lite initialization SQLs

import 'package:chain_activities/helpers/constants.dart';

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
      '$settingDataTypeBool'
    )
  ''',
];

// Constant Header Content

List<Map<String, String>> headerSlideContent = [
  {
    "imageAsset": assetMap["cat_intro"]!,
    //"https://raw.githubusercontent.com/vinaykhare/cat_help_content/main/help_images/0.png",
    "title": "Thanks for choosing CAT",
    "speech":
        "Thanks for choosing CAT. CAT is a tool to Chain the activities with the help of Timers.",
  },
  {
    "imageAsset": assetMap["chains"]!,
    //"https://raw.githubusercontent.com/vinaykhare/cat_help_content/main/help_images/0.png",
    "title": "Sample Chains",
    "speech":
        "Chains looks like this. CAT comes with these sample chains to start with. You can play it, stop it, make it favorite, remove it by swiping it right and also share and receive it in json format.",
  },
  {
    "imageAsset": assetMap["individual_chain"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/Chain%20Categories.png",
    "title": "Chain with Timer Activities",
    "speech":
        "This is how a Chain looks when we open it, just by tapping on it."
  },
  {
    "imageAsset": assetMap["play_chain"]!,
    // "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/Play%20Chain.gif",
    "title": "Play Chain",
    "speech":
        "Chain plays interactively. This is a sample screenshot of Play Chain screen. Timer keeps ticking every second, but you can pause it too.",
  },
  {
    "imageAsset": assetMap["share_chain"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
    "title": "Share the Chain.",
    "speech": "You can share the Chain in json format.",
  },
  {
    "imageAsset": assetMap["receive_chain"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
    "title": "Receive the Chain.",
    "speech": "And you can receive the Chain in json format too.",
  },
  {
    "imageAsset": assetMap["upload_chain"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
    "title": "Upload the Chain JSON.",
    "speech":
        "CAT also allows to recieve the Chain by uploading the json using Upload Button on Home Screen.",
  },
  {
    "imageAsset": assetMap["create_chain"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
    "title": "Create the Chain",
    "speech":
        "CAT provides a Simple UI to Create your own Chain of Timer Activities.",
  },
  {
    "imageAsset": assetMap["create_chain_1"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
    "title": "Create the Chain",
    "speech":
        "It starts with Create chain form where we need to give a unique name to our chain first and then we can add activities to it.",
  },
  {
    "imageAsset": assetMap["create_chain_2"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
    "title": "Create the Chain",
    "speech":
        "Chain keeps forming as we add activities to it using below form.",
  },
  {
    "imageAsset": assetMap["create_chain_3"]!,
    //"https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
    "title": "Create the Chain",
    "speech": "Activity with Hours, Minutes or ",
  },
  {
    "imageAsset": assetMap["go_home"]!,
    "title": "Now just Explore CAT",
    "speech": "Now just explore the CAT yourself. I believe that it will help.",
  },
];
