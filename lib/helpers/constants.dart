const int noValueInDB = -1;
const int trueInDB = 1;
const int falseInDB = 0;

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
const String repeatTypeDoesNotRepeat = "Never";
const String repeatTypeHourly = "Hourly";
const String repeatTypeDaily = "Daily";
const String repeatTypeWeekly = "Weekly";
const String repeatTypeMonthly = "Monthly";
const String repeatTypeYearly = "Yearly";
