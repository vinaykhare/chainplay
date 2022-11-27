import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/notifications/local_notification_service.dart';
import 'package:schedule_it/screens/acitivity_list_screen.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_rest_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/schedule_list_screen.dart';
import 'package:schedule_it/screens/search_schedule_screen.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import 'helpers/ad_state.dart';
import 'models/schedule_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService localNotifyService = LocalNotificationService();
  localNotifyService.initialize();
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
        ChangeNotifierProvider(
          //create: (context) => ScheduleList(context, adState),
          create: (context) => ScheduleList(context, localNotifyService),
        ),
      ],
      child: const ScheduleIt(),
    ),
  );
}

class ScheduleIt extends StatelessWidget {
  const ScheduleIt({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.amber.shade200,
        backgroundColor: Colors.lightGreen,
        cardColor: Colors.lightGreen,
        canvasColor: Colors.amber,
      ),
      //home: Schedules(),
      initialRoute: ScheduleListScreen.routename,
      routes: {
        ScheduleListScreen.routename: (context) => const ScheduleListScreen(),
        ActivityListScreen.routename: (context) => const ActivityListScreen(),
        AddScheduleScreen.routename: (context) => const AddScheduleScreen(),
        PlaySchedule.routename: (context) => const PlaySchedule(),
        PlayRest.routename: (context) => const PlayRest(),
        SearchScheduleScreen.routename: (context) =>
            const SearchScheduleScreen(),
      },
    );
  }
}
