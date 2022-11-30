import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/schedule_it.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'helpers/ad_state.dart';
import 'models/schedule_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        //   //create: (context) => ScheduleList(context, adState),
        //   create: (context) => LocalNotificationService(),
        // ),
        ChangeNotifierProvider(
          //create: (context) => ScheduleList(context, adState),
          create: (context) => ScheduleList(context),
        ),
      ],
      child: const ScheduleIt(),
    ),
  );
}
