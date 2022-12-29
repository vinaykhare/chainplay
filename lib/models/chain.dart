//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/models/chain_event.dart';

class Chain {
  String title = "";
  DateTime? at, endedAt;
  DateTime lastUpdatedAt = DateTime.now();
  DateTime createdAt = DateTime.now();
  List<ChainEvent> activities = [];
  List<Chain> chainHistory = [];
  String repeatType = repeatTypeDoesNotRepeat;
  int repeatTypeGap = repeatTypeDefaultGap;
  int repeatCount = repeatTypeDefaultCount;
  //BannerAd? adBanner;
  bool pinned = false;
  int chainStatus = statusNotStarted;
  int notificationId = noValueInDB;
  bool edit = true;
  int index = -1;
  String chainExecutionId = "";
}
