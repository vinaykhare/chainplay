const int noValueInDB = -1;
const int trueInDB = 1;
const int falseInDB = 0;

const String sampleWorkoutChainTitle = "Sample Workout Chain";
const String sampleDietRoutineChainTitle = "Sample Diet Routine Chain";
const String sampleMedicineRoutineChainTitle = "Sample Medicine Routine Chain";

// For Tutorial
const String idToGoToPlayWaitTutorialScreen =
    "Press the forward button to go back to Chain Activity Execution screen, where we can resume the Chain Activity Interactively.\nIf the chain is running in background then you will be asked if you really need to force complete the background activity and enter the interactive view of chain activity.";
const String idToGoToPlayChainScreen =
    "Press the back button to pause the Chain (if running) and go to the Screen where we can see the Chain Execution Status and take actions on the Chain.";

// Activity Specifications
const String activitySpecImagePath = "imagePath";
const String pixaBayApiKey = "49503054-f92036d9ea19800816b8e4902";
const String inUse = "Activities in use";
const String notInUse = "Activities not in use";

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
const String appSoundSettingKey = "GUIDED VOICE";
const String themeSettingKey = "THEME";
const String showHelpOnNextBootKey = "Need ChainPlay Introduction?";
const String tutorialFull = "Show full tutorial";
const String tutorialChainListScreen = "SHOW GUIDE ON HOME SCREEN";
const String tutorialViewChainScreen = "SHOW GUIDE ON VIEW CHAIN SCREEN";
const String tutorialAddChainScreen = "SHOW GUIDE ON ADD CHAIN SCREEN";
const String tutorialPlayChainScreen = "SHOW GUIDE ON PLAY CHAIN SCREEN";
// const String tutorialPlayWaitScreen = "SHOW GUIDE ON PLAY ACTIVITY SCREEN";
const String catClockModeKey = "ChainPlay Clock Mode";
const String catClockModeValue = "HH:MM:SS,HH:MM,AM/PM";
const String trueSettingValue = "TRUE";
const String falseSettingValue = "FALSE";
const String settingDataTypeBool = "BOOL";
const String settingDataTypeHiddenBool = "HIDDENBOOL";
const String settingDataTypeList = "LIST";
const String settingDataTypeHiddenList = "HIDDENLIST";
//Themes
const String themeAmber = "AMBER";
const String themeBlack = "BLACK";
const String themeWhite = "WHITE";
const String themeValueList = "$themeAmber,$themeBlack,$themeWhite";

//Notification Payload fields

const String payLoadChainName = "chainTitle";
const String payLoadChainExecId = "chainExecutionId";
const String payLoadWidgetUrl = "url";
const String payLoadChainActivityIndex = "chainActivityIndex";
const String payLoadChainActivityCount = "chainActivityCount";
const String payLoadChainAction = "action";

//Play Chain Page Load Optoins
const String playChainActionPlay = "play";
const String playChainActionPause = "pause";
const String playChainActionStop = "stop";
const String chainActivityCompletionMessageRestart = "Restart";
const String chainActivityCompletionMessageDone = "Done";

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
  'noImagePlaceholder': 'assets/AppIcons/no-Image-placeholder.png',
  'pixabaylogo': 'assets/AppIcons/pixabaylogo.png',
  'beepAudio': 'Sounds/chain_activity_beep.mp3',
  'chain_file_view': 'assets/WhatIsChainAndPlay/chain_file_view.jpeg',
  'sample_diet_routine_chain':
      'assets/SampleChains/Sample_Diet_Routine_Chain.json',
  'sample_medicine_routine_chain':
      'assets/SampleChains/Sample_Medicine_Routine_Chain.json',
  'sample_workout_chain': 'assets/SampleChains/Sample_Workout_Chain.json',
};
