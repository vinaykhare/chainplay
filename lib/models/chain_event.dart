import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/models/event.dart';

class ChainEvent {
  int startEventNotificationId = noValueInDB;
  int endEventNotificationId = noValueInDB;

  Duration eventDuration; // 0 = No time bound
  String repeatType;
  Duration? eventDurationLeft;
  bool eventDone = false, isInterrupted = false;
  DateTime? at, endedAt;
  Event event;
  bool edit = false;
  int index = -1;

  ChainEvent({
    required this.event,
    this.eventDuration = const Duration(seconds: 0),
    this.repeatType = repeatTypeDoesNotRepeat,
    this.eventDone = false,
  });
}
