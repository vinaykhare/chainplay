import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/chain_activities.dart';
import 'firebase_options.dart';
import 'models/chain_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  MobileAds.instance.initialize();
  // LocalNotificationService localNotifyService = LocalNotificationService();
  // localNotifyService.initialize();
  // final initMobileAds = MobileAds.instance.initialize();
  // final adState = AdState(initMobileAds);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
