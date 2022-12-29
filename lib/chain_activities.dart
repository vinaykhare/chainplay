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
              selectedRowColor: Colors.green.shade700,
            ),
      home: chainList.loaded
          ? chainList.notificationCameAs != null
              ? const PlayChain()
              : const ChainListScreen()
          : FutureBuilder(
              future: chainList.initialize(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LoadScreen();
                } else {
                  return const ChainListScreen();
                }
              },
            ),
      //initialRoute: LoadScreen.routename,
      routes: {
        ChainListScreen.routename: (context) => const ChainListScreen(),
        AddChainScreen.routename: (context) => const AddChainScreen(),
        PlayChain.routename: (context) => const PlayChain(),
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
