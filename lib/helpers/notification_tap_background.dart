// ignore_for_file: avoid_print

import 'dart:isolate';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

@pragma('vm:entry-point')
void alarmTapBackground(int x, Map<String, dynamic> mapResponse) {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print(
    "[$now] Hello Alarm Users! isolate=$isolateId function='$notificationTapBackground', from $x",
  );
}
