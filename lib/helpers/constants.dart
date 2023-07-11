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
const String eventNotificationsKey = "Event Notifications";
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
  'alarmAudio': 'assets/sound/chain_activity_alarm.wav',
  'beepAudio': 'assets/sound/chain_activity_beep.mp3',
  'go_home':
      'https://github.com/vinaykhare/cat_help_content/raw/main/help_images/go_home.png',
};
