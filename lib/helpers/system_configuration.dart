//SQF Lite initialization SQLs

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';

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
      'DARK THEME', 
      'FALSE',
      'BOOL'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      'Notification Type',
      'None,App Notification',
      'LIST'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      'App Sound', 
      'TRUE',
      'BOOL'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      'Show help on next boot', 
      'TRUE',
      'BOOL'
    )
  ''',
];

// Constant Header Content

const List<Map<String, String>> headerSlideContent = [
  {
    "imageAsset": "assets/help_images/0.png",
    "content": "CAT welcomes you. Lets check what is it and how it works.",
  },
  {
    "imageAsset": "assets/help_images/1.png",
    "content":
        "CAT allows you to create the chain of timers and schedule alarm to it.",
  },
  {
    "imageAsset": "assets/help_images/2.png",
    "content":
        "CAT comes with a Sample Chain of Timers to Start with. It is a simple workout schedule. You can add it by tapping this circle on Home Screen Or you can add your own Chain.",
  },
  {
    "imageAsset": "assets/help_images/3.png",
    "content":
        "You can create your own chain of Timers by Click this button on Home screen when there are not chains created.",
  },
  {
    "imageAsset": "assets/help_images/4.png",
    "content": "And you can always create your own chain from Menu here.",
  },
  {
    "imageAsset": "assets/help_images/5.png",
    "content":
        "Lets check what all can we do on a tile of a chain on Home Screen. Every unscheduled Chain has a Play Pause button to left. You can use it to play the chain right away, or stop the execution of running chain.",
  },
  {
    "imageAsset": "assets/help_images/9.png",
    "content":
        "Here, home screen has three Chains, with all possible stats of Play button.",
  },
  {
    "imageAsset": "assets/help_images/10.png",
    "content":
        "First chain is running, and we can stop by pressing pause button. Second chain is scheduled and we can wait for Local Notification. Thir chain is stopped, and we can play it by pressing play button. We go to the Edit Chain screen for scheduling it.",
  },
  {
    "imageAsset": "assets/help_images/6.png",
    "content":
        "Tapping on the body of Chain tile will take you to Screen where you can Edit Chain and Add Alarm to it.",
  },
  {
    "imageAsset": "assets/help_images/7.png",
    "content":
        "Forward arrow to the right of Chain takes you to the page with Chain Execution history.",
  },
  {
    "imageAsset": "assets/help_images/8.png",
    "content": "You can mark the chain as Favorite too.",
  },
  {
    "imageAsset": "",
    "content":
        "We hope you got the basics and ready to play around. Tap me to go to CAT Home.",
  },
];

List<Activity> sampleActivities = [
  Activity(
    activityId: "workout_activity_start",
    title: systemStartActivityInTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemStartActivityInDB,
  ),
  Activity(
    activityId: "workout_activity_rest",
    title: systemWaitActivityTitle,
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    type: systemWaitActivityInDB,
  ),
  Activity(
    title: "Jumping Jacks",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_jumping_jacks",
    specification: {
      activitySpecImagePath:
          "https://hips.hearstapps.com/hmg-prod/images/workouts/2016/03/jumpingjack-1457045563.gif?resize=1200:*",
    },
  ),
  Activity(
    title: "Push Ups & Rotations",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_pushups_and_rotations",
    specification: {
      activitySpecImagePath:
          "https://hips.hearstapps.com/hmg-prod/images/workouts/2016/04/tpushup-1461693226.gif?resize=1200:*",
    },
  ),
  Activity(
    title: "Burpees",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_burpees",
    specification: {
      activitySpecImagePath:
          "https://hips.hearstapps.com/hmg-prod/images/workouts/2016/03/burpee-1457045324.gif?resize=1200:*",
    },
  ),
  Activity(
    title: "Cobra Stretch",
    createdAt: DateTime.now(),
    lastUpdatedAt: DateTime.now(),
    activityId: "workout_activity_cobra_stretch",
    specification: {
      activitySpecImagePath:
          "https://img.freepik.com/premium-photo/athletic-woman-doing-cobra-pose-practicing-bhujangasana-yoga-stretching-back-muscles_416530-737.jpg?w=1060",
    },
  ),
];

Chain getChain(/** List<int> activityIndices */) {
  Chain sampleChain = Chain();
  sampleChain.title = "Sample Workout Chain";

  // for (int actIndex in activityIndices) {
  //   sampleChain.activities.add(ChainActivity(
  //     activity: sampleActivities[actIndex],
  //   ),);
  // }

  sampleChain.activities = [
    ChainActivity(
      activity: sampleActivities[0],
    ),
    ChainActivity(
      activity: sampleActivities[2],
      activityDuration: const Duration(seconds: 30),
    ),
    ChainActivity(
      activity: sampleActivities[1],
      activityDuration: const Duration(seconds: 0),
    ),
    ChainActivity(
      activity: sampleActivities[3],
      activityDuration: const Duration(seconds: 0),
    ),
    ChainActivity(
      activity: sampleActivities[1],
      activityDuration: const Duration(seconds: 25),
    ),
    ChainActivity(
      activity: sampleActivities[4],
    ),
    ChainActivity(
      activity: sampleActivities[1],
      activityDuration: const Duration(seconds: 15),
    ),
    ChainActivity(
      activity: sampleActivities[5],
      activityDuration: const Duration(seconds: 30),
    ),
    ChainActivity(
      activity: sampleActivities[1],
    ),
  ];

  return sampleChain;
}

List<Chain> sampleChains = [getChain()];
