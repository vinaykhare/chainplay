import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
  if (notificationResponse.payload != null) {
    Map<String, dynamic> responsePayload =
        jsonDecode(notificationResponse.payload!);
    Navigator.of(navigatorKey.currentContext!).pushNamed(PlaySchedule.routename,
        arguments: responsePayload[payLoadSchduleName]);
  }
}
