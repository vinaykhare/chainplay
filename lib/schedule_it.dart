import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/acitivity_list_screen.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/how_it_works.dart';
import 'package:schedule_it/screens/load_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';
import 'package:schedule_it/screens/play_activity_screen.dart';
import 'package:schedule_it/screens/schedule_activities_history_screen.dart';
import 'package:schedule_it/screens/schedule_history_screen.dart';
import 'package:schedule_it/screens/schedule_list_screen.dart';
import 'package:schedule_it/screens/search_schedule_screen.dart';
import 'package:schedule_it/screens/settings_screen.dart';

class ScheduleIt extends StatelessWidget {
  const ScheduleIt({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: true);
    int themeIndex = scheduleList.systemSettings.indexWhere(
      (set) => set.key == "DARK THEME",
    );
    bool darkTheme = themeIndex == -1
        ? false
        : scheduleList.systemSettings[themeIndex].value == "TRUE";
    return MaterialApp(
      title: 'Schedule It',
      darkTheme: darkTheme ? ThemeData.dark() : null,
      theme: darkTheme
          ? ThemeData(
              scaffoldBackgroundColor: const Color.fromARGB(255, 13, 14, 39),
              backgroundColor: const Color.fromARGB(255, 13, 14, 39),
              colorScheme: const ColorScheme.dark(),
              canvasColor: const Color.fromARGB(255, 19, 20, 57),
              cardColor: const Color.fromARGB(255, 19, 20, 57),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 13, 14, 39),
              ),
            )
          : ThemeData(
              primarySwatch: Colors.amber,
              scaffoldBackgroundColor: Colors.amber.shade200,
              backgroundColor: Colors.lightGreen,
              cardColor: Colors.lightGreen,
              canvasColor: Colors.amber,
              dialogBackgroundColor: Colors.lightGreen,
            ),
      home: scheduleList.loaded
          ? scheduleList.notificationCameAs != null
              ? const PlaySchedule()
              : const ScheduleListScreen()
          : FutureBuilder(
              future: scheduleList.initialize(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadScreen();
                } else {
                  return const ScheduleListScreen();
                }
              },
            ),
      //initialRoute: LoadScreen.routename,
      routes: {
        ScheduleListScreen.routename: (context) => const ScheduleListScreen(),
        ActivityListScreen.routename: (context) => const ActivityListScreen(),
        AddScheduleScreen.routename: (context) => const AddScheduleScreen(),
        PlaySchedule.routename: (context) => const PlaySchedule(),
        SearchScheduleScreen.routename: (context) =>
            const SearchScheduleScreen(),
        SettingsScreen.routename: (context) => const SettingsScreen(),
        PlayActivity.routename: (context) => const PlayActivity(),
        LoadScreen.routename: (context) => const LoadScreen(),
        HowItWorks.routename: (context) => const HowItWorks(),
        ScheduleHistoryScreen.routename: (context) =>
            const ScheduleHistoryScreen(),
        ScheduleActivitiesHistoryScreen.routename: (context) =>
            const ScheduleActivitiesHistoryScreen(),
      },
    );
  }
}
