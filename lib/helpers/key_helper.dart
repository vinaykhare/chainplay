import 'package:flutter/material.dart';

class KeyHelper {
  static GlobalKey<NavigatorState>? navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "Chain_Activities_Debug_NavState");

  static GlobalKey homeCatKey = GlobalKey();
  static GlobalKey chainListKey = GlobalKey();
  static GlobalKey chainControlSummaryKey = GlobalKey();
  static GlobalKey minmaxChainControlSummaryKey = GlobalKey();
  static GlobalKey searchChainKey = GlobalKey();
  static GlobalKey uploadChainButtonKey = GlobalKey();
  static GlobalKey createNewChainButtonKey = GlobalKey();
  static GlobalKey viewChainKey = GlobalKey();
}
