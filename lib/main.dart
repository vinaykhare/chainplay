import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/chain_activities.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'helpers/ad_state.dart';
import 'models/chain_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
