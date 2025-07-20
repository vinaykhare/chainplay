const int noValueInDB = -1;
const int trueInDB = 1;
const int falseInDB = 0;

const String sampleWorkoutChainTitle = "Sample Workout Chain";
const String sampleDietRoutineChainTitle = "Sample Diet Routine Chain";
const String sampleMedicineRoutineChainTitle = "Sample Medicine Routine Chain";

// For Tutorial

// const String idToShowHideAppDrawer =
//     "You can hide it or keep it, just by clicking this expand shrink button";
const String idToLoadSampleChainForTutorial =
    "If both the filters are selected then app will display both active and favorite chains. For example, if one chain is Favorite but not active and other chain is active but not favorite, then selecting both filters will disply both the chains.";
const String idToStartViewChain =
    "Now Lets take this Sample Workout Chain as an example to understand a Chain and its features";
const String idToStartAddChain =
    "Now Lets press this edit button and check how add or edit chain screen looks.";
const String idToGoBackToViewChain =
    "Just press this back button when you are done with Chain Editing. It will automatically save the changes and exit from this screen.";
const String idToPlayChain =
    "Now we will see that how a chain can be played. We can play by pressing this button. This button is avialable on the Chain tile at Home screen too.";
const String idToPauseTheChain =
    "We can pause the chain activity and resume it back with this button and hence the chain.";
const String idToGoToChainExecutionStatusScreen =
    "Press the back button to pause the Chain (if running) and go to the Screen where we can see the Chain Execution Status and take actions on the Chain.";
const String idToComeBackToHome =
    "This quick tutorial has covered the major features of the app. Now explore yourself and reach out to us for any help. We hope that you will make the most out of this App. Lets press the back button to end this tutorial and go back to the home screen.";

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
const String darkThemeSettingKey = "DARK THEME";
const String showHelpOnNextBootKey = "Need ChainPlay Introduction?";
const String catClockModeKey = "ChainPlay Clock Mode";
const String catClockModeValue = "HH:MM:SS,HH:MM,AM/PM";
const String trueSettingValue = "TRUE";
const String falseSettingValue = "FALSE";
const String settingDataTypeBool = "BOOL";
const String settingDataTypeHiddenBool = "HIDDENBOOL";
const String settingDataTypeList = "LIST";
const String settingDataTypeHiddenList = "HIDDENLIST";

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
  'beepAudio': 'assets/Sounds/chain_activity_beep.mp3',
  'app_drawer': 'assets/WhatIsChainAndPlay/app_drawer.jpeg',
  'chain_file_view': 'assets/WhatIsChainAndPlay/chain_file_view.jpeg',
  'sample_diet_routine_chain':
      'assets/SampleChains/Sample_Diet_Routine_Chain.json',
  'sample_medicine_routine_chain':
      'assets/SampleChains/Sample_Medicine_Routine_Chain.json',
  'sample_workout_chain': 'assets/SampleChains/Sample_Workout_Chain.json',
};
