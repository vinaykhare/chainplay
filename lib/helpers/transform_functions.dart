import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/models/system_setting.dart';

class TransformFunctions {
  static String durationToString(Duration eventDuration) {
    String drStr = "in ";
    int eventDurationHour = eventDuration.inHours;
    if (eventDurationHour != 0) {
      if (drStr != "in ") {
        drStr += ", ";
      }
      drStr += "${eventDurationHour.toString().padLeft(2, '0')} Hours";
    }

    int eventDurationMinute =
        eventDuration.inMinutes - (eventDurationHour * 60);
    if (eventDurationMinute != 0) {
      if (drStr != "in ") {
        drStr += ", ";
      }
      drStr += "${eventDurationMinute.toString().padLeft(2, '0')} Minutes";
    }

    int eventDurationSecond = eventDuration.inSeconds -
        (eventDurationMinute * 60) -
        (eventDurationHour * 3600);

    if (eventDurationSecond != 0) {
      if (drStr != "in ") {
        drStr += " and ";
      }
      drStr += "${eventDurationSecond.toString().padLeft(2, '0')} Seconds";
    }
    return drStr == "in " ? "on Pressing Done." : drStr;
  }

  static String durationToRestString(Duration eventDuration) {
    String drStr = "";
    int eventDurationHour = eventDuration.inHours;
    if (eventDurationHour != 0) {
      if (drStr != "") {
        drStr += ", ";
      }
      drStr += "${eventDurationHour.toString().padLeft(2, '0')} Hours";
    }

    int eventDurationMinute =
        eventDuration.inMinutes - (eventDurationHour * 60);
    if (eventDurationMinute != 0) {
      if (drStr != "") {
        drStr += ", ";
      }
      drStr += "${eventDurationMinute.toString().padLeft(2, '0')} Minutes";
    }

    int eventDurationSecond = eventDuration.inSeconds -
        (eventDurationMinute * 60) -
        (eventDurationHour * 3600);

    if (eventDurationSecond != 0) {
      if (drStr != "") {
        drStr += " and ";
      }
      drStr += "${eventDurationSecond.toString().padLeft(2, '0')} Seconds";
    }
    return drStr;
  }

  static String notificationSettingIsFor(List<SystemSetting> systemSettings) {
    SystemSetting notificationSettingValue = systemSettings
        .firstWhere((set) => set.key == notificationTypeSettingKey);
    return notificationSettingValue.value.split(",")[0];
  }
}
