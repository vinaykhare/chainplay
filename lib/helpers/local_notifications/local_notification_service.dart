//import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';
import 'dart:convert';
//import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chain_activities/helpers/notification_tap_background.dart';
import 'package:chain_activities/helpers/local_notifications/received_notification.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/timezone.dart';

class LocalNotificationService with WidgetsBindingObserver {
  LocalNotificationService();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String? selectedNotificationPayload;

  /// A notification action which triggers a url launch event
  static const String urlLaunchActionId = 'id_1';

  /// A notification action which triggers a App navigation event
  static const String navigationActionId = 'id_3';

  /// Defines a iOS/MacOS notification category for text input actions.
  static const String darwinNotificationCategoryText = 'textCategory';

  /// Defines a iOS/MacOS notification category for plain actions.
  static const String darwinNotificationCategoryPlain = 'plainCategory';

  static const String portName = 'notification_send_port';
  static const MethodChannel platform =
      MethodChannel('dexterx.dev/flutter_local_notifications_example');

  /// Streams are created so that app can respond to notification-related events
  /// since the plugin is initialised in the `main` function
  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();

  // final StreamController<String?> selectNotificationStream =
  //     StreamController<String?>.broadcast();

  //late InitializationSettings initializationSettings;

  Future<void> initialize() async {
    initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation("timeZoneName"));
    //Android settings
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/launcher_icon');

    // IOS Settings

    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        darwinNotificationCategoryText,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            'text_1',
            'Action 1',
            buttonTitle: 'Send',
            placeholder: 'Placeholder',
          ),
        ],
      ),
      DarwinNotificationCategory(
        darwinNotificationCategoryPlain,
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2 (destructive)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            navigationActionId,
            'Action 3 (foreground)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'id_4',
            'Action 4 (auth required)',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.authenticationRequired,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
      notificationCategories: darwinNotificationCategories,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsDarwin,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: notificationTapBackground,
      //     (NotificationResponse notificationResponse) async {
      //   switch (notificationResponse.notificationResponseType) {
      //     case NotificationResponseType.selectedNotification:
      //       selectNotificationStream.add(notificationResponse.payload);
      //       break;
      //     case NotificationResponseType.selectedNotificationAction:
      //       if (notificationResponse.actionId ==
      //           LocalNotificationService.navigationActionId) {
      //         selectNotificationStream.add(notificationResponse.payload);
      //       }
      //       break;
      //   }
      // },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<Map<String, dynamic>?> checkForNotification() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    Map<String, dynamic>? result;

    // selectNotificationStream.stream.listen((String? payload) async {
    //   result =
    //       payload != null ? jsonDecode(payload) as Map<String, dynamic> : {};
    // });

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
      "CHAIN_EVENTS_CHANNEL_ID",
      "CHAIN_EVENTS_CHANNEL_NAME",
      channelDescription: 'CAT Channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'CAT',
      playSound: true,
      sound: const RawResourceAndroidNotificationSound(
          'chain_activity_alarm'), //android\app\src\main\res\raw\chain_activity_alarm.wav
      // sound: UriAndroidNotificationSound(
      //     assetMap['alarmAudio']!,
      fullScreenIntent: true,
      // styleInformation: BigPictureStyleInformation(
      //   DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      //   largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      //   contentTitle: 'CAT Big Picture Notification Title',
      //   summaryText: 'CAT Big Picture Notification Title',
      // ),
      showProgress: true,
      maxProgress: maxProgressVal,
      progress: progressVal,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    return notificationDetails;
  }

  Future<NotificationDetails> _getNotificationWithActions() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "CHAIN_EVENTS_CHANNEL_ID",
      "CHAIN_EVENTS_CHANNEL_NAME",
      channelDescription: 'CAT Channel with Action.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'CAT',
      sound: RawResourceAndroidNotificationSound('chain_activity_alarm'),
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        // AndroidNotificationAction(
        //   urlLaunchActionId,
        //   'Action 1',
        //   icon: DrawableResourceAndroidBitmap('@drawable/ic_launcher'),
        //   contextual: true,
        // ),
        AndroidNotificationAction(
          'id_2',
          'Done',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        // AndroidNotificationAction(
        //   navigationActionId,
        //   'Action 3',
        //   icon: DrawableResourceAndroidBitmap('@drawable/ic_launcher'),
        //   showsUserInterface: true,
        //   // By default, Android plugin will dismiss the notification when the
        //   // user tapped on a action (this mimics the behavior on iOS).
        //   cancelNotification: false,
        // ),
      ],
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    return notificationDetails;
  }

  Future<void> showNotificationWithActions(
    int notificationId,
    Map<String, String> payLoad,
  ) async {
    final details = await _getNotificationWithActions();
    await flutterLocalNotificationsPlugin.show(notificationId,
        'plain title with action', 'plain body with aciton', details,
        payload: jsonEncode(payLoad));
  }

  Future<void> showNotification(
    int notificationId,
    int maxProgVal,
    int progVal,
    Map<String, String> payLoad,
  ) async {
    final details = await _getNotification(maxProgVal, progVal);
    await flutterLocalNotificationsPlugin.show(
        notificationId, 'plain title', 'plain body', details,
        payload: jsonEncode(payLoad));
  }

  Future<bool> scheduleNotificationWithAction(
    DateTime chainAt,
    int notificationId,
    String title,
    String body,
    Map<String, String> payLoad,
  ) async {
    try {
      final details = await _getNotificationWithActions();
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        TZDateTime.from(chainAt, local),
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        payload: jsonEncode(payLoad),
      );
      return true;
    } catch (e) {
      return false;
    }
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
        notificationId,
        title,
        body,
        TZDateTime.from(chainAt, local),
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        payload: jsonEncode(payLoad),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cancelScheduledNotification(int notificationId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
