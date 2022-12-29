const int noValueInDB = -1;
const int trueInDB = 1;
const int falseInDB = 0;

// Activity Specifications
const String activitySpecImagePath = "imagePath";

//Event types
const int systemStartEventInDB = 0;
const int systemWaitEventInDB = 1;
const int waitEventInDB = 2;

//System Event Names
const String systemWaitEventTitle = "System Wait Event";
const String systemStartEventInTitle = "System Start Event";

//Status

const int statusNotStarted = 0;
const int statusDone = 1;
const int statusExecuting = 2;

//Settings
const String appSoundSettingKey = "App Sound";
const String darkThemeSettingKey = "DARK THEME";
const String trueSettingValue = "TRUE";
const String falseSettingValue = "FALSE";

const String notificationTypeSettingKey = "Notification Type";
const String notificationTypeSettingValueAppNotify = "App Notification";
const String notificationTypeSettingValueAlarm = "Alarm";
const String notificationTypeSettingValueCalendar = "Calendar";
const String notificationTypeSettingValueNone = "None";
const String notificationTypeSettingValueAll = "All";

//Notification Payload fields

const String payLoadChainName = "chainTitle";
const String payLoadChainExecId = "chainExecutionId";
const String payLoadWidgetUrl = "url";
const String payLoadChainEventIndex = "chainEventIndex";
const String payLoadChainEventCount = "chainEventCount";

//Schedule Repeat Types
const int repeatTypeDefaultGap = 1;
const int repeatTypeDefaultCount = -1;
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
