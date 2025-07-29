import 'package:flutter/services.dart';

class CommonLogic {
  Future<bool> setOrietation(bool isLandscape) async {
    if (isLandscape) {
      await SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
    } else {
      await SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
    }
    return isLandscape;
  }
}
