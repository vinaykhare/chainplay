import 'package:flutter/material.dart';

class KeyHelper {
  // Notification Routing
  static GlobalKey<NavigatorState>? navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "Chain_Activities_Debug_NavState");

  // ChainListScreen
  static GlobalKey chainListScreenAppBarkey = GlobalKey();
  static GlobalKey chainListSearchkey = GlobalKey();

  //View Chain Screen
  static GlobalKey viewChainKey = GlobalKey();
  static GlobalKey viewChainOptionsKey = GlobalKey();
  static GlobalKey viewChainBottomBarKey = GlobalKey();
  static GlobalKey viewChainEditButtonKey = GlobalKey();
  static GlobalKey viewChainPlayChainKey = GlobalKey();
  static GlobalKey viewChainScheduleChainKey = GlobalKey();
  static GlobalKey viewChainTitleKey = GlobalKey();

  //Play Chain Screen
  static GlobalKey playChainKey = GlobalKey();
  static GlobalKey playChainTitleKey = GlobalKey();
  static GlobalKey playChainStopChainKey = GlobalKey();
  static GlobalKey playChainRunInBackgroundKey = GlobalKey();
  static GlobalKey playChainRotateScreenKey = GlobalKey();
  static GlobalKey playChainForwardButtonKey = GlobalKey();

  //Play Wait Activity Screen
  static GlobalKey playWaitKey = GlobalKey();
  static GlobalKey playWaitTitleKey = GlobalKey();
  static GlobalKey playWaitRotateScreenKey = GlobalKey();
  static GlobalKey playWaitPlayPauseKey = GlobalKey();
  static GlobalKey playWaitGoBackAndNotifyKey = GlobalKey();
  static GlobalKey playWaitTimerKey = GlobalKey();
  static GlobalKey playWaitForwardKey = GlobalKey();
  static GlobalKey playWaitBackwardKey = GlobalKey();

  // Add Chain Screen
  static GlobalKey addChainKey = GlobalKey();
  static GlobalKey addChainAddActivitySpecificationBarKey = GlobalKey();
  static GlobalKey addChainTitleKey = GlobalKey();
  static GlobalKey addChainSaveAndExitKey = GlobalKey();
  static GlobalKey addChainAddActivityBarKey = GlobalKey();

  // ListOfChainsTutorial
  static GlobalKey chainControlSummaryKey = GlobalKey();
  static GlobalKey chainFiltersKey = GlobalKey();
  static GlobalKey chainListKey = GlobalKey();
  static GlobalKey sampleWorkoutChainListItemKey = GlobalKey();
  static GlobalKey sampleDietChainListItemKey = GlobalKey();
  static GlobalKey sampleMedicineChainListItemKey = GlobalKey();

  // ChainListItem
  static GlobalKey sampleWorkoutChainViewKey = GlobalKey();
  static GlobalKey sampleDietChainViewKey = GlobalKey();
  static GlobalKey sampleMedicineChainViewKey = GlobalKey();

  //ChainListHeaderTutorial
  static GlobalKey homeChainAndPlayKey = GlobalKey();
  static GlobalKey chainAndPlayTitle = GlobalKey();
  static GlobalKey uploadChainButtonKey = GlobalKey();
  static GlobalKey createNewChainButtonKey = GlobalKey();
}
