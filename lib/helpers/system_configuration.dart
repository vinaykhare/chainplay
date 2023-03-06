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
      'App Notification,None',
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
    "imageAsset": "assets/help_images/app_drawer_menu.png",
    "content": "Get Menu items by pressing the Burger Icon.",
  },
  {
    "imageAsset": "assets/help_images/check_executions.png",
    "content": "Check the chain Execution history.",
  },
  {
    "imageAsset": "assets/help_images/home.png",
    "content": "Home Screen with List of Chains.",
  },
  {
    "imageAsset": "assets/help_images/howitworks.png",
    "content": "Check Help Menu for all App Features and its usage.",
  },
  {
    "imageAsset": "assets/help_images/mark_favorite.png",
    "content": "You can mark the chains as favorite, and filter them fast.",
  },
  {
    "imageAsset": "assets/help_images/play_chain.png",
    "content": "Play the chain of Activitites by pressing the play Button.",
  },
  {
    "imageAsset": "assets/help_images/search_chains.png",
    "content":
        "Search the chains when list of chain grows and its difficult to look out the desired chain.",
  },
  {
    "imageAsset": "assets/help_images/settings.png",
    "content":
        "Control the settings for this app like Dark Theme, App Notification etc.",
  },
  {
    "imageAsset": "assets/help_images/start_chain.png",
    "content":
        "Edit Chain to Schedule for future execution, just by tapping on Start.",
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
