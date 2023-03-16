//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/local_notifications/local_notification_service.dart';

import 'package:chain_activities/models/system_setting.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class NotificationHelper {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  List<SystemSetting> systemSettings = [];
  FlutterTts? flutterTts;
  bool speakerInitialized = false;

  set systemSetting(List<SystemSetting> newSystemSettings) {
    systemSettings = newSystemSettings;
  }

  Future<void> initialize(List<SystemSetting> systemSettingsFromRoot) async {
    systemSettings = systemSettingsFromRoot;
    await localNotificationService.initialize();
  }

  Future<bool?> askNotificationPermission() async {
    return await localNotificationService.askNotificationPermission();
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
      await localNotificationService.cancelScheduledNotification(id);
    }
    // if (notificationFor == notificationTypeSettingValueAlarm) {
    //   AndroidAlarmManager.cancel(id);
    // }
  }

  Future<void> playNotificationSound() async {
    if (isAppSoundEnabled()) {
      //await FlutterRingtonePlayer.playNotification();
      // await FlutterRingtonePlayer.play(
      //   fromAsset: assetMap['beepAudio']!,
      // );
      final player = AudioPlayer();
      player.setAsset(assetMap['beepAudio']!);

      player.play();
    }
  }

  Future<FlutterTts?> speakText(String text) async {
    if (isAppSoundEnabled() && !speakerInitialized) {
      flutterTts = FlutterTts();
      await flutterTts!.awaitSpeakCompletion(true);
      speakerInitialized = true;
    }
    if (isAppSoundEnabled()) {
      await flutterTts!.speak(text);
      return flutterTts;
    }
    return null;
  }

  Future<void> stopSpeech() async {
    if (isAppSoundEnabled() && flutterTts != null) {
      await flutterTts!.stop();
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
