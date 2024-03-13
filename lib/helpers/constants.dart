const int noValueInDB = -1;
const int trueInDB = 1;
const int falseInDB = 0;

// Activity Specifications
const String activitySpecImagePath = "imagePath";

//Activity types
const int systemStartActivityInDB = 0;
const int systemWaitActivityInDB = 1;
const int waitActivityInDB = 2;
const int systemEndActivityInDB = 3;

//System Activity Names
const String systemWaitActivityTitle = "System Wait Activity";
const String systemStartActivityInTitle = "System Start Activity";

//Status

const int statusNotStarted = 0;
const int statusDone = 1;
const int statusExecuting = 2;

//Settings Set Response

const int setSuccessful = 0;
const int setFailed = 1;
const int setFailedDueToAppPermission = 2;

//Settings
const String appSoundSettingKey = "App Sound";
const String darkThemeSettingKey = "DARK THEME";
const String showHelpOnNextBootKey = "Need CAT Introduction?";
const String catClockModeKey = "Cat Clock Mode";
const String catClockModeValue = "HH:MM:SS,HH:MM,AM/PM";
const String trueSettingValue = "TRUE";
const String falseSettingValue = "FALSE";
const String settingDataTypeBool = "BOOL";
const String settingDataTypeList = "LIST";

//Notification Payload fields

const String payLoadChainName = "chainTitle";
const String payLoadChainExecId = "chainExecutionId";
const String payLoadWidgetUrl = "url";
const String payLoadChainActivityIndex = "chainActivityIndex";
const String payLoadChainActivityCount = "chainActivityCount";

//Schedule Repeat Types
const int repeatTypeDefaultGap = 1;
const int repeatTypeDefaultCount = 0;
const String repeatTypeDoesNotRepeat = "Never";
const String repeatTypeSecond = "Second";
const String repeatTypeMinute = "Minute";
const String repeatTypeHourly = "Hour";
const String repeatTypeDaily = "Day";
const String repeatTypeWeekly = "Week";
const String repeatTypeMonthly = "Month";
const String repeatTypeYearly = "Year";
const String repeatOccurAfter = "After";
const String repeatOccurNever = "Never";

//assets
const Map<String, String> assetMap = {
  'logoImage': 'assets/AppIcons/playstore.png',
  'chainImage': 'assets/AppIcons/chain.png',
  'verticalChainImage': 'assets/AppIcons/vertical_chain.png',
  'beepAudio': 'assets/Sounds/chain_activity_beep.mp3',
  'go_home': 'assets/WhatIsCAT/go_home.png',
  'cat_intro': 'assets/WhatIsCAT/cat_intro.png',
  'individual_chain': 'assets/WhatIsCAT/individual_chain.jpeg',
  'chains': 'assets/WhatIsCAT/chains.jpeg',
  'play_chain': 'assets/WhatIsCAT/play_chain.jpeg',
  'share_chain': 'assets/WhatIsCAT/share_chain.jpeg',
  'receive_chain': 'assets/WhatIsCAT/receive_chain.jpeg',
  'upload_chain': 'assets/WhatIsCAT/upload_chain.jpeg',
  'create_chain': 'assets/WhatIsCAT/create_chain.jpeg',
  'zero_duration': 'assets/WhatIsCAT/zero_duration.jpeg',
  'settings': 'assets/WhatIsCAT/settings.jpeg',
  'appdrawer': 'assets/WhatIsCAT/appdrawer.jpeg',
  'sample_diet_routine_chain':
      'assets/SampleChains/Sample_Diet_Routine_Chain.json',
  'sample_medicine_routine_chain':
      'assets/SampleChains/Sample_Medicine_Routine_Chain.json',
  'sample_workout_chain': 'assets/SampleChains/Sample_Workout_Chain.json',
};
