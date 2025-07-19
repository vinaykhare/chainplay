class ContentTransformer {
  static String durationToString(Duration activityDuration) {
    String drStr = "in ";
    int activityDurationHour = activityDuration.inHours;
    if (activityDurationHour != 0) {
      if (drStr != "in ") {
        drStr += ", ";
      }
      drStr += "${activityDurationHour.toString().padLeft(2, '0')} Hours";
    }

    int activityDurationMinute =
        activityDuration.inMinutes - (activityDurationHour * 60);
    if (activityDurationMinute != 0) {
      if (drStr != "in ") {
        drStr += ", ";
      }
      drStr += "${activityDurationMinute.toString().padLeft(2, '0')} Minutes";
    }

    int activityDurationSecond = activityDuration.inSeconds -
        (activityDurationMinute * 60) -
        (activityDurationHour * 3600);

    if (activityDurationSecond != 0) {
      if (drStr != "in ") {
        drStr += " and ";
      }
      drStr += "${activityDurationSecond.toString().padLeft(2, '0')} Seconds";
    }
    return drStr == "in " ? "on Pressing Done." : drStr;
  }

  static String durationToRestString(Duration activityDuration) {
    String drStr = "";
    int activityDurationHour = activityDuration.inHours;
    if (activityDurationHour != 0) {
      if (drStr != "") {
        drStr += ", ";
      }
      drStr += "${activityDurationHour.toString().padLeft(2, '0')} Hours";
    }

    int activityDurationMinute =
        activityDuration.inMinutes - (activityDurationHour * 60);
    if (activityDurationMinute != 0) {
      if (drStr != "") {
        drStr += ", ";
      }
      drStr += "${activityDurationMinute.toString().padLeft(2, '0')} Minutes";
    }

    int activityDurationSecond = activityDuration.inSeconds -
        (activityDurationMinute * 60) -
        (activityDurationHour * 3600);

    if (activityDurationSecond != 0) {
      if (drStr != "") {
        drStr += " and ";
      }
      drStr += "${activityDurationSecond.toString().padLeft(2, '0')} Seconds";
    }
    return drStr;
  }

  // static String notificationSettingIsFor(List<SystemSetting> systemSettings) {
  //   SystemSetting notificationSettingValue =
  //       systemSettings.firstWhere((set) => set.key == eventNotificationsKey);
  //   return notificationSettingValue.value.split(",")[0];
  // }
}
