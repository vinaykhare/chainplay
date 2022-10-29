import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/screens/add_activity_screen.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_rest_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/schedule_list_screen.dart';
import 'package:schedule_it/screens/schedule_screen.dart';

import 'models/schedule_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScheduleIt());
}

class ScheduleIt extends StatelessWidget {
  const ScheduleIt({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ScheduleList(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: Colors.amber.shade200,
          backgroundColor: Colors.lightGreen,
          cardColor: Colors.lightGreen,
        ),
        //home: Schedules(),
        initialRoute: ScheduleListScreen.routename,
        routes: {
          ScheduleListScreen.routename: (context) => const ScheduleListScreen(),
          ScheduleScreen.routename: (context) => const ScheduleScreen(),
          AddScheduleScreen.routename: (context) => const AddScheduleScreen(),
          PlaySchedule.routename: (context) => const PlaySchedule(),
          PlayRest.routename: (context) => const PlayRest(),
          AddActivityScreen.routename: (context) => const AddActivityScreen(),
        },
      ),
    );
  }
}
