import 'dart:convert';

import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.payload != null) {
    Map<String, dynamic> responsePayload =
        jsonDecode(notificationResponse.payload!);
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
}
