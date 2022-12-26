import 'package:chain_events/helpers/constants.dart';

class Event {
  String eventId;
  String title;
  int type;
  DateTime createdAt, lastUpdatedAt;
  bool edit = false;

  Event({
    required this.eventId,
    required this.title,
    required this.createdAt,
    required this.lastUpdatedAt,
    this.type = waitEventInDB,
  });
}
