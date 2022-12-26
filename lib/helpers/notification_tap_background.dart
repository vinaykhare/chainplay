import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:schedule_it/helpers/constants.dart';
import 'package:schedule_it/helpers/key_helper.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  //GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
  if (notificationResponse.payload != null) {
    Map<String, dynamic> responsePayload =
        jsonDecode(notificationResponse.payload!);
    Navigator.of(KeyHelper.navigatorKey!.currentContext!)
        .pushNamed(PlaySchedule.routename, arguments: {
      payLoadSchduleExecId: responsePayload[payLoadSchduleExecId],
      payLoadSchduleName: responsePayload[payLoadSchduleName],
      payLoadWidgetUrl: responsePayload[payLoadWidgetUrl],
      payLoadScheduleActivityIndex:
          responsePayload[payLoadScheduleActivityIndex],
      payLoadScheduleActivityCount:
          responsePayload[payLoadScheduleActivityCount],
    });
  }
}
