import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/tutorial/screens/add_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/chain_list_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/play_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/play_wait_activity_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/view_chain_screen_tutorial.dart';
import 'package:chain_activities/widgets/my_error_widget.dart';
import 'package:chain_activities/widgets/redirect.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/tutorial/screens/how_it_works.dart';
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
        : chainList.systemSettings[themeIndex].value == trueSettingValue;
    return MaterialApp(
      title: 'CAT',
      builder: (context, widget) {
        Widget error = const Scaffold(body: Center(child: MyErrorWidget()));
        ErrorWidget.builder = (errorDetails) => error;
        if (widget != null) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: widget,
          );
        }
        throw ('widget is null');
      },
      //darkTheme: darkTheme ? ThemeData.dark() : null,
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
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.black;
                    } else {
                      return Colors.grey;
                    }
                  },
                ),
                trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.grey;
                  } else {
                    return Colors.black;
                  }
                }),
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
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => Colors.amber,
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => Colors.black,
                  ),
                ),
              ),
              listTileTheme: const ListTileThemeData(
                tileColor: Colors.amber,
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.amber;
                    } else {
                      return Colors.lightGreen;
                    }
                  },
                ),
                trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.lightGreen;
                  } else {
                    return Colors.amber;
                  }
                }),
              ),
              drawerTheme: const DrawerThemeData(
                backgroundColor: Colors.amber,
              ),
              dividerTheme: DividerThemeData(
                color: Colors.amber.shade200,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.amber,
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: Colors.amber.shade400,
              ),
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
        ChainListScreenTutorial.routename: (context) =>
            const ChainListScreenTutorial(),
        AddChainScreen.routename: (context) => const AddChainScreen(),
        AddChainScreenTutorial.routename: (context) =>
            const AddChainScreenTutorial(),
        PlayChain.routename: (context) => const PlayChain(),
        PlayChainTutorial.routename: (context) => const PlayChainTutorial(),
        SearchChainScreen.routename: (context) => const SearchChainScreen(),
        SettingsScreen.routename: (context) => const SettingsScreen(),
        PlayWaitActivity.routename: (context) => const PlayWaitActivity(),
        PlayWaitActivityTutorial.routename: (context) =>
            const PlayWaitActivityTutorial(),
        LoadScreen.routename: (context) => const LoadScreen(),
        HowItWorks.routename: (context) => const HowItWorks(),
        ChainExecutionScreen.routename: (context) =>
            const ChainExecutionScreen(),
        ViewChain.routename: (context) => const ViewChain(),
        ViewChainTutorial.routename: (context) => const ViewChainTutorial(),
      },
    );
  }
}
