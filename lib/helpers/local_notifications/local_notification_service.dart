import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_service;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chain_activities/helpers/notification_tap_background.dart';
import 'package:chain_activities/helpers/local_notifications/received_notification.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/timezone.dart';
import 'package:chain_activities/helpers/key_helper.dart';
// import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const flutter_service.MethodChannel platform =
      flutter_service.MethodChannel(
          'promaxbiz.com/flutter_local_notifications');

  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  Future<void> initialize() async {
    initializeTimeZones();
    TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
    // Temp fix due to Asia/Calcutta rename issue
    // if (timeZoneName.identifier == "Asia/Calcutta") {
    //   timeZoneName. = "Asia/Kolkata";
    // }
    setLocalLocation(getLocation(timeZoneName.identifier == "Asia/Calcutta"
        ? "Asia/Kolkata"
        : timeZoneName.identifier));
    //Android settings
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/launcher_icon');

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    didReceiveLocalNotificationStream.stream.listen(
      (ReceivedNotification receivedNotification) async {},
    );

    selectNotificationStream.stream.listen((String? payload) async {
      if (payload != null) {
        Map<String, dynamic> responsePayload = jsonDecode(payload);
        Navigator.of(KeyHelper.navigatorKey!.currentContext!)
            .pushReplacementNamed(PlayChain.routename, arguments: {
          payLoadChainExecId: responsePayload[payLoadChainExecId],
          payLoadChainName: responsePayload[payLoadChainName],
          payLoadWidgetUrl: responsePayload[payLoadWidgetUrl],
          payLoadChainActivityIndex: responsePayload[payLoadChainActivityIndex],
          payLoadChainActivityCount: responsePayload[payLoadChainActivityCount],
          payLoadChainAction: responsePayload[payLoadChainAction],
        });
      }
    });
  }

  Future<bool> isAndroidPermissionGranted() async {
    bool granted = false;
    if (Platform.isAndroid) {
      granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
    return granted;
  }

  Future<bool> askNotificationPermission() async {
    // bool scheudleExactAlarmPermission =
    //     await Permission.scheduleExactAlarm.request().isGranted;
    bool notificationPermission = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false;
    bool exactAlarmPermission = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission() ??
        false;
    return notificationPermission && exactAlarmPermission;
  }

  Future<Map<String, dynamic>?> checkForNotification() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    Map<String, dynamic>? result;

    if (notificationAppLaunchDetails != null) {
      if (notificationAppLaunchDetails.didNotificationLaunchApp) {
        NotificationResponse? notificationResponse =
            notificationAppLaunchDetails.notificationResponse;

        if (notificationResponse != null) {
          String? response = notificationResponse.payload;
          if (response != null) {
            result = jsonDecode(response) as Map<String, dynamic>;
          }
        }
      }

      notificationAppLaunchDetails = null;
    }

    return result;
  }

  Future<NotificationDetails> _getNotification(
      int maxProgressVal, int progressVal) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "CAT_TEST_CHANNEL_2",
      "CAT_TEST_CHANNEL_N2",
      channelDescription: 'ChainPlay Channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ChainPlay',
      // actions: <AndroidNotificationAction>[
      //   AndroidNotificationAction(
      //     progressVal.toString(),
      //     'Snooze',
      //     icon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      //     contextual: true,
      //   ),
      // ],
      playSound: true,
      sound: const RawResourceAndroidNotificationSound(
        'chain_activity_alarm',
      ),
      fullScreenIntent: false,
      showProgress: true,
      maxProgress: maxProgressVal,
      progress: progressVal,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    return notificationDetails;
  }

  Future<bool> scheduleNotification(
    DateTime chainAt,
    int notificationId,
    String title,
    String body,
    Map<String, dynamic> payLoad,
  ) async {
    try {
      final details = await _getNotification(
        payLoad["chainActivityCount"],
        payLoad["chainActivityIndex"],
      );
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: TZDateTime.from(chainAt, local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: jsonEncode(payLoad),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelScheduledNotification(int notificationId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id: notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
