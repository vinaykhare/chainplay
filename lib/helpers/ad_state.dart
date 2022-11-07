// ignore_for_file: avoid_print

import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);
  String get bannerAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-3940256099942544/2934735716";

  BannerAdListener get adListener => _adListener;

  final BannerAdListener _adListener = BannerAdListener(
    /*
    onAdLoaded: (ad) => print('Ad wit Ad Unit Id: ${ad.adUnitId} is Loaded.'),
    onAdClosed: (ad) => print('Ad wit Ad Unit Id: ${ad.adUnitId} is Closed.'),
    onAdOpened: (ad) => print('Ad wit Ad Unit Id: ${ad.adUnitId} is Opened.'),
    onAdFailedToLoad: (ad, error) =>
        print('Ad with ${ad.adUnitId} has failed to Load due to Error: $error'),
    onAdClicked: (ad) => print('Ad wit Ad Unit Id: ${ad.adUnitId} is Clicked.'),
    onPaidEvent: (ad, db, prec, st) =>
        print('Ad wit Ad Unit Id: ${ad.adUnitId} is Opened.'),
    onAdWillDismissScreen: (ad) =>
        print('Ad wit Ad Unit Id: ${ad.adUnitId} is Dismissed.'), */
    onAdLoaded: (ad) {},
    onAdClosed: (ad) {
      ad.dispose();
    },
    onAdOpened: (ad) {},
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
    },
    onAdClicked: (ad) {},
    onPaidEvent: (ad, db, prec, st) {},
    onAdWillDismissScreen: (ad) {
      ad.dispose();
    },
  );
}
