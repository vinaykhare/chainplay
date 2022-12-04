import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/helpers/local_notifications/local_notification_service.dart';

import 'package:schedule_it/models/system_setting.dart';

class NotificationHelper {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  List<SystemSetting> systemSettings = [];
  String? notificationCameForScheduleName;
  String? notificaitonCameForUrl;

  set systemSetting(List<SystemSetting> newSystemSettings) {
    systemSettings = newSystemSettings;
  }

  Future<void> initialize(List<SystemSetting> systemSettingsFromRoot) async {
    systemSettings = systemSettingsFromRoot;
    await localNotificationService.initialize();

    Map<String, dynamic>? responsePayload =
        await localNotificationService.checkForNotification();

    if (responsePayload != null) {
      notificaitonCameForUrl = responsePayload["url"];
      notificationCameForScheduleName = responsePayload["scheduleName"];
    } else {
      notificationCameForScheduleName = notificaitonCameForUrl = null;
    }
  }

  Future<int> scheduleNotification(DateTime scheduleAt, int notificationId,
      String title, String body, Map<String, String> payload) async {
    String notificationFor = notificationSettingIsFor();
    if (notificationFor == notificationTypeSettingValueAppNotify) {
      if (await localNotificationService.scheduleNotification(
          scheduleAt, notificationId, title, body, payload)) {
        return notificationId;
      }
    }
    // if (notificationFor == notificationTypeSettingValueAlarm) {
    //   if (await AndroidAlarmManager.oneShotAt(
    //     scheduleAt,
    //     notificationId,
    //     alarmTapBackground,
    //     alarmClock: true,
    //     wakeup: true,
    //   )) {
    //     return notificationId;
    //   }
    // }
    return noValueInDB;
  }

  Future<void> cancelNotificationById(int id) async {
    String notificationFor = notificationSettingIsFor();
    if (notificationFor == notificationTypeSettingValueAppNotify) {
      await localNotificationService.cancelScheduledNotification(id);
    }
    // if (notificationFor == notificationTypeSettingValueAlarm) {
    //   AndroidAlarmManager.cancel(id);
    // }
  }

  Future<void> playNotificationSound() async {
    if (isAppSoundEnabled()) {
      await FlutterRingtonePlayer.playNotification();
    }
  }

  //helper functions

  SystemSetting getSettingByKey(String key) {
    return systemSettings.firstWhere((set) => set.key == key);
  }

  String notificationSettingIsFor() {
    return getSettingByKey(notificationTypeSettingKey).value.split(",")[0];
  }

  bool isAppSoundEnabled() {
    return getSettingByKey(appSoundSettingKey).value == trueSettingValue;
  }
}
