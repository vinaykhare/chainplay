//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_activity.dart';

class Chain {
  String title = "";
  DateTime? at, endedAt, pivotDate;
  DateTime lastUpdatedAt = DateTime.now();
  DateTime createdAt = DateTime.now();
  List<ChainActivity> activities = [];
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

  Chain();

  factory Chain.fromJson(Map<String, dynamic> jsonMap) {
    Chain chain = Chain();
    chain.title = jsonMap['title'];
    chain.at = jsonMap['at'] != null ? DateTime.parse(jsonMap['at']) : null;
    chain.endedAt =
        jsonMap['endedAt'] != null ? DateTime.parse(jsonMap['endedAt']) : null;
    chain.pivotDate = jsonMap['pivotDate'] != null
        ? DateTime.parse(jsonMap['pivotDate'])
        : null;
    chain.lastUpdatedAt = DateTime.parse(jsonMap['lastUpdatedAt']);
    chain.createdAt = DateTime.parse(jsonMap['createdAt']);
    chain.edit = jsonMap['edit'];
    List<dynamic> listOfChainActivityJson = jsonMap['activities'];
    for (var chainActivityJson in listOfChainActivityJson) {
      chain.activities.add(
        ChainActivity.fromJson(chainActivityJson as Map<String, dynamic>),
      );
    }
    return chain;
    // return Chain(
    //   title: map['title'],
    //   at: DateTime.parse(map['at']),
    //   endedAt: DateTime.parse(map['endedAt']),
    //   pivotDate: DateTime.parse(map['pivotDate']),
    // );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "at": at?.toIso8601String(),
      "endedAt": endedAt?.toIso8601String(),
      "pivotDate": pivotDate?.toIso8601String(),
      "lastUpdatedAt": lastUpdatedAt.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "edit": false,
      "activities": activities,
    };
  }
}
