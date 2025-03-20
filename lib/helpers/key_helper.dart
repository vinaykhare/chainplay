import 'package:flutter/material.dart';

class KeyHelper {
  static GlobalKey<NavigatorState>? navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "Chain_Activities_Debug_NavState");

  static GlobalKey homeChainAndPlayKey = GlobalKey();
  static GlobalKey chainAndPlayTitle = GlobalKey();

  static GlobalKey chainListKey = GlobalKey();
  static GlobalKey sampleWorkoutChainListItemKey = GlobalKey();
  static GlobalKey sampleDietChainListItemKey = GlobalKey();
  static GlobalKey sampleMedicineChainListItemKey = GlobalKey();

  static GlobalKey sampleWorkoutChainViewKey = GlobalKey();
  static GlobalKey sampleDietChainViewKey = GlobalKey();
  static GlobalKey sampleMedicineChainViewKey = GlobalKey();

  static GlobalKey sampleWorkoutChainTileKey = GlobalKey();
  static GlobalKey sampleDietChainTileKey = GlobalKey();
  static GlobalKey sampleMedicineChainTileKey = GlobalKey();

  static GlobalKey chainControlSummaryKey = GlobalKey();
  static GlobalKey minmaxChainControlSummaryKey = GlobalKey();
  static GlobalKey chianListScreenAppBarkey = GlobalKey();
  static GlobalKey chianListSearchkey = GlobalKey();
  static GlobalKey chainFiltersKey = GlobalKey();
  static GlobalKey activeChainFilterKey = GlobalKey();
  static GlobalKey favoriteChainFilterKey = GlobalKey();
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
  static GlobalKey playWaitGoBackAndNotifyKey = GlobalKey();
  static GlobalKey playWaitTimerKey = GlobalKey();
  static GlobalKey playWaitPlayPauseKey = GlobalKey();
  static GlobalKey playWaitForwardKey = GlobalKey();
}
