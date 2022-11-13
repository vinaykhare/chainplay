import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/screens/acitivity_list_screen.dart';
import 'package:schedule_it/screens/add_activity_screen.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_rest_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/schedule_list_screen.dart';
import 'package:schedule_it/screens/schedule_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'helpers/ad_state.dart';
import 'models/schedule_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  runApp(
    MultiProvider(
      providers: [
        Provider.value(
          value: adState,
        ),
        ChangeNotifierProvider(
          create: (context) => ScheduleList(context, adState),
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
        ScheduleScreen.routename: (context) => const ScheduleScreen(),
        AddScheduleScreen.routename: (context) => const AddScheduleScreen(),
        PlaySchedule.routename: (context) => const PlaySchedule(),
        PlayRest.routename: (context) => const PlayRest(),
        AddActivityScreen.routename: (context) => const AddActivityScreen(),
      },
    );
  }
}
