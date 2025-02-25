import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/chain_activities.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'helpers/ad_state.dart';
import 'models/chain_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  // LocalNotificationService localNotifyService = LocalNotificationService();
  // localNotifyService.initialize();
  // final initMobileAds = MobileAds.instance.initialize();
  // final adState = AdState(initMobileAds);

  runApp(
    MultiProvider(
      providers: [
        // Provider.value(
        //   value: localNotifyService,
        // ),
        // Provider.value(
        //   value: adState,
        // ),
        // Provider(
        //   //create: (context) => ChainList(context, adState),
        //   create: (context) => LocalNotificationService(),
        // ),
        ChangeNotifierProvider(
          //create: (context) => ChainList(context, adState),
          create: (context) => ChainList(context),
        ),
      ],
      child: const ChainActivities(),
    ),
  );
}
