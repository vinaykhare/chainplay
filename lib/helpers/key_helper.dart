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
  static GlobalKey viewChainOptionsKey = GlobalKey();
  static GlobalKey viewChainBottomBarKey = GlobalKey();
  static GlobalKey viewChainEditButtonKey = GlobalKey();

  static GlobalKey addChainKey = GlobalKey();
  static GlobalKey addChainTitleKey = GlobalKey();
  static GlobalKey addChainAddActivityBarKey = GlobalKey();
  static GlobalKey addChainAddActivitySpecificationBarKey = GlobalKey();
  static GlobalKey addChainSaveAndExitKey = GlobalKey();

  static GlobalKey viewChainPlayChainKey = GlobalKey();

  static GlobalKey playChainKey = GlobalKey();
  static GlobalKey playChainRunInBackgroundKey = GlobalKey();
  static GlobalKey playChainStopChainKey = GlobalKey();
  static GlobalKey playChainForwardButtonKey = GlobalKey();
  static GlobalKey playChainBackwardButtonKey = GlobalKey();

  static GlobalKey playWaitKey = GlobalKey();
  static GlobalKey playWaitBackwardKey = GlobalKey();
  static GlobalKey playWaitTimerKey = GlobalKey();
  static GlobalKey playWaitPlayPauseKey = GlobalKey();
  static GlobalKey playWaitForwardKey = GlobalKey();
}
