import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/helpers/key_helper.dart';
import 'package:chain_events/screens/play_chain_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  //GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
  if (notificationResponse.payload != null) {
    Map<String, dynamic> responsePayload =
        jsonDecode(notificationResponse.payload!);
    Navigator.of(KeyHelper.navigatorKey!.currentContext!)
        .pushNamed(PlayChain.routename, arguments: {
      payLoadChainExecId: responsePayload[payLoadChainExecId],
      payLoadChainName: responsePayload[payLoadChainName],
      payLoadWidgetUrl: responsePayload[payLoadWidgetUrl],
      payLoadChainEventIndex: responsePayload[payLoadChainEventIndex],
      payLoadChainEventCount: responsePayload[payLoadChainEventCount],
    });
  }
}
