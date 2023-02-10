import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/screens/show_chain_from_notification.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    Map<String, dynamic> responsePayload =
        jsonDecode(notificationResponse.payload!);
    Navigator.of(KeyHelper.navigatorKey!.currentContext!)
        .pushReplacementNamed(ShowChainFromNotification.routename, arguments: {
      payLoadChainExecId: responsePayload[payLoadChainExecId],
      payLoadChainName: responsePayload[payLoadChainName],
      payLoadWidgetUrl: responsePayload[payLoadWidgetUrl],
      payLoadChainActivityIndex: responsePayload[payLoadChainActivityIndex],
      payLoadChainActivityCount: responsePayload[payLoadChainActivityCount],
    });
  }
}
