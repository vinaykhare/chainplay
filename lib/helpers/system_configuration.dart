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
      '$eventNotificationsKey',
      '$trueSettingValue',
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

const List<Map<String, String>> headerSlideContent = [
  {
    "imageAsset":
        "https://raw.githubusercontent.com/vinaykhare/cat_help_content/main/help_images/0.png",
    "title": "C A T,\nChain the Alarms & Timers.",
    "speech":
        "What is CAT.  Well. CAT is all about the Chains. Chain of Timers and Chain of Alarms. CAT allows you to create the Chain of Timers, and play it. CAT also allows you to add Alarms like a usual Clock, plus, it allows you to run your chosen 'Chain of Timers' when Alarm rings. So, we can Chain the Timers, and, we can Chain the Alarms, at user defined 'Timer Intervals'.",
  },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/home%20page.png",
  //   "title": "CAT Home\n on first load.",
  //   "speech":
  //       "CAT comes with a Sample Chain of Timers to Start with. Sample includes Workout Chain, Diet Chain and a Medicine Schedule chain. When there are no chains created, home page of CAT gives the option to add these sample chains or create your own.",
  // },
  {
    "imageAsset":
        "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/Chain%20Categories.png",
    "title": "Chain Categories",
    "speech":
        "This way, CAT has three Categories of Chains. One, Chain of Timers, which we can play interactively. Second, Scheduled Chain of Timers which executes chain of timers in backgroud at scheduled time. It prompts User for completing Manual Actvities defined in Chain and also for completing the chain in the end. And third, Scheduled Chain without Timers, which acts as Alarm Clock."
  },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/Create%20Chain.gif",
  //   "title": "Create Chain of Timer Activities",
  //   "speech":
  //       "Lets check how we create the Chain of Timer Activities. CAT Interface to create chain allows us to add Manual and Timer Actvities to the chain. Any activity with default zero duration is treated as Manual Activity. This requires user intervention to complete activity during chain execution. If check box is checked, then activity is considered done and it will be skipped while chain execution. User can edit the Activity Added into chain by tapping over it, or remove it by swiping it right.",
  // },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/Play%20Chain.gif",
  //   "title": "Play Chain of Timer Activities",
  //   "speech":
  //       "Listed Tiles of Chais on Home Screen has a button to play or stop the chain. Playing the Chain of Timer Activities takes us to play Chain screen, where we can see the current timer, pause it, skip it and check the Chain Execution status by going back.",
  // },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/Create%20Scheduled%20Chain.gif",
  //   "title": "Create Scheduled Chain\nor Alarm",
  //   "speech":
  //       "Lets check how we create the Scheduled Chain of Timer Activities or Alarm. Tap the Digital clock on CAT Home. It will prompt you to select a Future Time & Date for Alarm. You can select the options to repeat its occurance and frequency, and same will reflect on screen. CAT allows you to add Manual or Timer activities to this just created alarm, and conver the Alarm into Scheduled Chain of Timer Activities.",
  // },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/Play%20Scheduled%20Chain.gif",
  //   "title": "Play Scheduled Chain of Timers or Alarms",
  //   "speech":
  //       "As soon as we exit the Scheduled Chain Creation screen, Alarm is scheduled to start the chain at selected time in future. When time comes, user gets the Notification about the start and completion of Timer Activities in the Chain. If Chain has Manual Activity that is a Timer activity with Zero duration, then tapping on Chain notification shall take you to the screen to mark Activity completion manually.",
  // },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/Stop%20Chains.gif",
  //   "title": "Stop the Running and Scheduled Chains",
  //   "speech":
  //       "When the Chains are running or scheduled then we see the Stop or Clock button instead of Play Button. Pressing this button will stop the chain. Once stopped, chain will again be listed with Play button.",
  // },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/Filter%20Chains.gif",
  //   "title": "Filter Chains",
  //   "speech":
  //       "There can be chances when you want to filter the number of chains listed on Home. We can filter them with predefined filters of Favorite Chain and Running Chain. We can use text filter to search by Chain Name of name of activity inside the chain.",
  // },
  // {
  //   "imageAsset":
  //       "https://github.com/vinaykhare/cat_help_content/raw/main/help_images/gif/CAT%20Settings.gif",
  //   "title": "CAT Settings\n Enable $eventNotificationsKey in Settings.",
  //   "speech":
  //       "CAT Settings helps you with your preferences. Notfication type is set to None by default. Please set it to App Notification so enable the feature to Schedule the chains. And, CAT has Dark theme too.",
  // },
  {
    "imageAsset": "",
    "title": "Now just Explore CAT",
    "speech":
        "I hope you understand CAT now. Now just explore it yourself. I am sure it will help.",
  },
];
