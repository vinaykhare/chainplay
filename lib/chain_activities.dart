import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/tutorial/screens/add_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/chain_list_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/play_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/play_wait_activity_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/view_chain_screen_tutorial.dart';
import 'package:chain_activities/widgets/my_error_widget.dart';
import 'package:chain_activities/widgets/palette_light_amber.dart';
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
              scaffoldBackgroundColor: const Color.fromARGB(255, 95, 96, 96),
              cardColor: const Color.fromARGB(255, 63, 63, 63),
              canvasColor: const Color.fromARGB(255, 58, 58, 59),
              colorScheme: const ColorScheme.dark(
                background: Color.fromARGB(255, 91, 91, 94),
                primary: Colors.grey,
                onPrimary: Colors.white,
              ),
              dialogBackgroundColor: Colors.black,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => Colors.grey,
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => Colors.white,
                  ),
                  textStyle: MaterialStateProperty.resolveWith(
                    (states) => Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              iconButtonTheme: IconButtonThemeData(
                style: ButtonStyle(
                  iconColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.amber,
                  ),
                ),
              ),
              iconTheme: const IconThemeData(
                //size: 10,
                color: Colors.amber,
                opacity: 1,
              ),
              listTileTheme: const ListTileThemeData(
                tileColor: Colors.black,
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
              drawerTheme: const DrawerThemeData(
                backgroundColor: Colors.black,
              ),
              dividerTheme: DividerThemeData(
                color: Colors.grey.shade200,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 53, 53, 55),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                fillColor: Color.fromARGB(255, 63, 63, 63),
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.black.withOpacity(0.5),
                cursorColor: Colors.white,
                selectionHandleColor: Colors.amber,
              ),
              textTheme: const TextTheme(
                titleMedium: TextStyle(
                  color: Colors.amber,
                ),
                titleLarge: TextStyle(
                  color: Colors.amber,
                ),
                titleSmall: TextStyle(
                  color: Colors.amber,
                ),
                bodyMedium: TextStyle(
                  color: Colors.amber,
                ),
                bodyLarge: TextStyle(
                  color: Colors.amber,
                ),
                bodySmall: TextStyle(
                  color: Colors.amber,
                ),
                headlineMedium: TextStyle(
                  color: Colors.amber,
                ),
                headlineLarge: TextStyle(
                  color: Colors.amber,
                ),
                headlineSmall: TextStyle(
                  color: Colors.amber,
                ),
                displayMedium: TextStyle(
                  color: Colors.amber,
                ),
                displayLarge: TextStyle(
                  color: Colors.amber,
                ),
                displaySmall: TextStyle(
                  color: Colors.amber,
                ),
                labelMedium: TextStyle(
                  color: Colors.amber,
                ),
                labelLarge: TextStyle(
                  color: Colors.amber,
                ),
                labelSmall: TextStyle(
                  color: Colors.amber,
                ),
              ),
            )
          : ThemeData(
              primarySwatch: PaletteLigthAmber.ligthAmber,
              scaffoldBackgroundColor: PaletteLigthAmber.ligthAmber.shade100,
              cardColor: Colors.lightGreen,
              canvasColor: PaletteLigthAmber.ligthAmber,
              colorScheme: ColorScheme.light(
                background: Colors.lightGreen,
                primary: PaletteLigthAmber.ligthAmber.shade300,
                onPrimary: Colors.black,
              ),
              dialogBackgroundColor: Colors.lightGreen,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => PaletteLigthAmber.ligthAmber,
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => Colors.black,
                  ),
                  textStyle: MaterialStateProperty.resolveWith(
                    (states) => Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              listTileTheme: ListTileThemeData(
                tileColor: PaletteLigthAmber.ligthAmber,
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return PaletteLigthAmber.ligthAmber;
                    } else {
                      return Colors.lightGreen;
                    }
                  },
                ),
                trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.lightGreen;
                  } else {
                    return PaletteLigthAmber.ligthAmber;
                  }
                }),
              ),
              drawerTheme: DrawerThemeData(
                backgroundColor: PaletteLigthAmber.ligthAmber,
              ),
              dividerTheme: DividerThemeData(
                color: PaletteLigthAmber.ligthAmber.shade200,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: PaletteLigthAmber.ligthAmber,
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: PaletteLigthAmber.ligthAmber.shade200,
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.lightGreen.withOpacity(0.5),
                cursorColor: Colors.black,
                selectionHandleColor: Colors.lightGreen,
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
