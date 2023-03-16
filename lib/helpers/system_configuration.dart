//SQF Lite initialization SQLs

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
        "CAT comes with a Sample Chain of Timers to Start with. Sample includes Workout Chain, Diet Chain and a Medicine Schedule chain. You can add it by tapping this circle on Home Screen Or you can add your own Chain.",
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
    "imageAsset": "assets/help_images/11.png",
    "content":
        "You can also add a Scheduled Chain by tapping on Clock on Home Screen. This takes you to add/edit chain scren where you will add Alarm to Chain first and then Timer Activities to it optionally. This way you can also use the Chain as Alarm with various options to repeat it.",
  },
  {
    "imageAsset": "assets/help_images/12.png",
    "content":
        "Local Notifications are disabled by Default in App Settings. To use Scheduled chain or Alarms, you need to set App Notification as Notification Type in App Settings, and give Notification Permissions to this app by going to Android Settings. Else Notifications and Alarms will not work in this app.",
  },
  {
    "imageAsset": "",
    "content":
        "We hope you got the basics and ready to play around. Tap me to go to CAT Home.",
  },
];
