//import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:chain_activities/helpers/constants.dart';
// import 'package:chain_activities/helpers/local_notifications/local_notification_service.dart';
import 'package:chain_activities/helpers/tts_state.dart';

import 'package:chain_activities/models/system_setting.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class NotificationHelper {
  // LocalNotificationService localNotificationService =
  //     LocalNotificationService();
  List<SystemSetting> systemSettings = [];
  FlutterTts? flutterTts;
  bool speakerInitialized = false;
  TtsState ttsState = TtsState.stopped;

  get isTtsPlaying => ttsState == TtsState.playing;
  get isTtsStopped => ttsState == TtsState.stopped;
  get isTtsPaused => ttsState == TtsState.paused;
  get isTtsContinued => ttsState == TtsState.continued;

  set systemSetting(List<SystemSetting> newSystemSettings) {
    systemSettings = newSystemSettings;
  }

  Future<void> initialize(List<SystemSetting> systemSettingsFromRoot) async {
    systemSettings = systemSettingsFromRoot;
    // await localNotificationService.initialize();
  }

  Future<bool> askNotificationPermission() async {
    // return await localNotificationService.askNotificationPermission();
    return false;
  }

  Future<Map<String, dynamic>?> checkForNotification() async {
    // Map<String, dynamic>? responsePayload =
    //     await localNotificationService.checkForNotification();

    // return responsePayload;
    return null;
  }

  Future<int> scheduleNotification(DateTime chainAt, int notificationId,
      String title, String body, Map<String, dynamic> payload) async {
    // if (await localNotificationService.scheduleNotification(
    //     chainAt, notificationId, title, body, payload)) {
    //   return notificationId;
    // }
    // return noValueInDB;
    return 0;
  }

  Future<void> cancelNotificationById(int id) async {
    // await localNotificationService.cancelScheduledNotification(id);
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

  Future<void> initTts() async {
    flutterTts = FlutterTts();
    await flutterTts!.awaitSpeakCompletion(true);
    flutterTts!.setStartHandler(() {
      ttsState = TtsState.playing;
    });
    flutterTts!.setCompletionHandler(() {
      ttsState = TtsState.stopped;
    });
    flutterTts!.setCancelHandler(() {
      ttsState = TtsState.stopped;
    });
    flutterTts!.setPauseHandler(() {
      ttsState = TtsState.paused;
    });
    flutterTts!.setContinueHandler(() {
      ttsState = TtsState.continued;
    });

    flutterTts!.setErrorHandler((msg) {
      ttsState = TtsState.stopped;
    });

    await flutterTts!.setSpeechRate(0.4);
  }

  Future<dynamic> speakText(String text) async {
    if (isAppSoundEnabled() && !speakerInitialized) {
      await initTts();
      speakerInitialized = true;
    }
    if (isAppSoundEnabled()) {
      return await flutterTts!.speak(text);
    }
    return null;
  }

  Future<void> speakTextWithoutWait(String text) async {
    if (isAppSoundEnabled() && !speakerInitialized) {
      await initTts();
      speakerInitialized = true;
    }
    if (isAppSoundEnabled()) {
      flutterTts!.speak(text);
    }
  }

  Future<dynamic> stopSpeech() async {
    if (isAppSoundEnabled() && flutterTts != null) {
      var result = await flutterTts!.stop();
      if (result == 1) {
        ttsState = TtsState.stopped;
      }
    }
  }

  //helper functions

  SystemSetting getSettingByKey(String key) {
    return systemSettings.firstWhere((set) => set.key == key);
  }

  // bool eventNotificationsEnabled() {
  //   //return getSettingByKey(eventNotificationsKey).value.split(",")[0];
  //   return getSettingByKey(eventNotificationsKey).value == trueSettingValue;
  // }

  bool isAppSoundEnabled() {
    return getSettingByKey(appSoundSettingKey).value == trueSettingValue;
  }
}
