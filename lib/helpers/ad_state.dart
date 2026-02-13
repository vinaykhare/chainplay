// ignore_for_file: avoid_print

//import 'dart:io';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  // Sample AdUnitId
  // String get bannerAdUnitId => Platform.isAndroid
  //     ? "ca-app-pub-3940256099942544/6300978111"
  //     : "ca-app-pub-3940256099942544/2934735716";

  // String get interstitialAdUnitId => Platform.isAndroid
  //     ? "ca-app-pub-3940256099942544/1033173712"
  //     : "ca-app-pub-3940256099942544/4411468910";

  //from AdMob
  /*
  String get bannerAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3219363933680144/2646139169"
      : "ca-app-pub-3940256099942544/2934735716";

  String get interstitialAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3219363933680144/1245453235"
      : "ca-app-pub-3940256099942544/4411468910";
  */
  //Test AdUnits
  String get bannerAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/9214589741"
      : "ca-app-pub-3940256099942544/2435281174";

  String get interstitialAdUnitId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/1033173712"
      : "ca-app-pub-3940256099942544/4411468910";

  BannerAdListener get adListener => _adListener;

  final BannerAdListener _adListener = BannerAdListener(
    onAdLoaded: (ad) {},
    onAdClosed: (ad) {
      ad.dispose();
    },
    onAdOpened: (ad) {},
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
    },
    onAdClicked: (ad) {},
    onAdWillDismissScreen: (ad) {
      ad.dispose();
    },
  );
}
