import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/screens/show_chain_from_notification.dart';
import 'package:chain_activities/widgets/redirect.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/how_it_works.dart';
import 'package:chain_activities/screens/load_screen.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/screens/play_wait_activity_screen.dart';
import 'package:chain_activities/screens/chain_execution_screen.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/screens/settings_screen.dart';

class ChainActivities extends StatelessWidget {
  const ChainActivities({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    int themeIndex = chainList.systemSettings.indexWhere(
      (set) => set.key == "DARK THEME",
    );
    bool darkTheme = themeIndex == -1
        ? false
        : chainList.systemSettings[themeIndex].value == "TRUE";
    return MaterialApp(
      title: 'Chain Activities',
      darkTheme: darkTheme ? ThemeData.dark() : null,
      debugShowCheckedModeBanner: false,
      theme: darkTheme
          ? ThemeData(
              primarySwatch: Colors.grey,
              scaffoldBackgroundColor: const Color.fromARGB(255, 56, 57, 57),
              canvasColor: const Color.fromARGB(255, 11, 11, 12),
              cardColor: const Color.fromARGB(255, 52, 52, 67),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 53, 53, 55),
              ),
              textTheme: const TextTheme(
                titleMedium: TextStyle(
                  color: Colors.white,
                ),
                titleLarge: TextStyle(
                  color: Colors.white,
                ),
                titleSmall: TextStyle(
                  color: Colors.white,
                ),
                bodyMedium: TextStyle(
                  color: Colors.white,
                ),
                bodyLarge: TextStyle(
                  color: Colors.white,
                ),
                bodySmall: TextStyle(
                  color: Colors.white,
                ),
                headlineMedium: TextStyle(
                  color: Colors.white,
                ),
                headlineLarge: TextStyle(
                  color: Colors.white,
                ),
                headlineSmall: TextStyle(
                  color: Colors.white,
                ),
                displayMedium: TextStyle(
                  color: Colors.white,
                ),
                displayLarge: TextStyle(
                  color: Colors.white,
                ),
                displaySmall: TextStyle(
                  color: Colors.white,
                ),
                labelMedium: TextStyle(
                  color: Colors.white,
                ),
                labelLarge: TextStyle(
                  color: Colors.white,
                ),
                labelSmall: TextStyle(
                  color: Colors.white,
                ),
              ),
              colorScheme: const ColorScheme.dark(
                background: Color.fromARGB(255, 91, 91, 94),
                primary: Colors.grey,
                onPrimary: Colors.white,
              ),
            )
          : ThemeData(
              primarySwatch: Colors.amber,
              scaffoldBackgroundColor: Colors.amber.shade200,
              cardColor: Colors.lightGreen,
              canvasColor: Colors.amber,
              colorScheme: const ColorScheme.light(
                background: Colors.lightGreen,
                primary: Colors.amber,
                onPrimary: Colors.black,
              ),
              dialogBackgroundColor: Colors.lightGreen,
              textTheme: const TextTheme(
                titleMedium: TextStyle(
                  color: Colors.black,
                ),
                titleLarge: TextStyle(
                  color: Colors.black,
                ),
                titleSmall: TextStyle(
                  color: Colors.black,
                ),
                bodyMedium: TextStyle(
                  color: Colors.black,
                ),
                bodyLarge: TextStyle(
                  color: Colors.black,
                ),
                bodySmall: TextStyle(
                  color: Colors.black,
                ),
                headlineMedium: TextStyle(
                  color: Colors.black,
                ),
                headlineLarge: TextStyle(
                  color: Colors.black,
                ),
                headlineSmall: TextStyle(
                  color: Colors.black,
                ),
                displayMedium: TextStyle(
                  color: Colors.black,
                ),
                displayLarge: TextStyle(
                  color: Colors.black,
                ),
                displaySmall: TextStyle(
                  color: Colors.black,
                ),
                labelMedium: TextStyle(
                  color: Colors.black,
                ),
                labelLarge: TextStyle(
                  color: Colors.black,
                ),
                labelSmall: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
      home: FutureBuilder(
        future: Provider.of<ChainList>(context, listen: false).initialize(),
        builder: (ctx, snap) {
          if (!chainList.loaded) {
            return const LoadScreen();
          } else {
            return const Redirect();
          }
        },
      ),
      //initialRoute: LoadScreen.routename,
      navigatorKey: KeyHelper.navigatorKey,
      routes: {
        ChainListScreen.routename: (context) => const ChainListScreen(),
        AddChainScreen.routename: (context) => const AddChainScreen(),
        PlayChain.routename: (context) => const PlayChain(),
        ShowChainFromNotification.routename: (context) =>
            const ShowChainFromNotification(),
        SearchChainScreen.routename: (context) => const SearchChainScreen(),
        SettingsScreen.routename: (context) => const SettingsScreen(),
        PlayWaitActivity.routename: (context) => const PlayWaitActivity(),
        LoadScreen.routename: (context) => const LoadScreen(),
        HowItWorks.routename: (context) => const HowItWorks(),
        ChainExecutionScreen.routename: (context) =>
            const ChainExecutionScreen(),
      },
    );
  }
}
