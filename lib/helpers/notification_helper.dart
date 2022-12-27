import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/helpers/local_notifications/local_notification_service.dart';

import 'package:chain_events/models/system_setting.dart';

class NotificationHelper {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  List<SystemSetting> systemSettings = [];

  set systemSetting(List<SystemSetting> newSystemSettings) {
    systemSettings = newSystemSettings;
  }

  Future<void> initialize(List<SystemSetting> systemSettingsFromRoot) async {
    systemSettings = systemSettingsFromRoot;
    await localNotificationService.initialize();
  }

  Future<Map<String, dynamic>?> checkForNotification() async {
    Map<String, dynamic>? responsePayload =
        await localNotificationService.checkForNotification();

    return responsePayload;
  }

  Future<int> scheduleNotification(DateTime chainAt, int notificationId,
      String title, String body, Map<String, dynamic> payload) async {
    String notificationFor = notificationSettingIsFor();
    if (notificationFor == notificationTypeSettingValueAppNotify) {
      if (await localNotificationService.scheduleNotification(
          chainAt, notificationId, title, body, payload)) {
        return notificationId;
      }
    }
    // if (notificationFor == notificationTypeSettingValueAlarm) {
    //   if (await AndroidAlarmManager.oneShotAt(
    //     chainAt,
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
      await localNotificationService.cancelChaindNotification(id);
    }
    // if (notificationFor == notificationTypeSettingValueAlarm) {
    //   AndroidAlarmManager.cancel(id);
    // }
  }

  Future<void> playNotificationSound() async {
    if (isAppSoundEnabled()) {
      //await FlutterRingtonePlayer.playNotification();
      await FlutterRingtonePlayer.play(
        fromAsset: "assets/sound/chain_event_beep.mp3",
      );
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
