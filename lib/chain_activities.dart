import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/screens/pixabay_selection_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/tutorial/screens/add_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/play_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/play_wait_activity_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/view_chain_screen_tutorial.dart';
import 'package:chain_activities/widgets/my_error_widget.dart';
import 'package:chain_activities/widgets/palette_dark.dart';
import 'package:chain_activities/widgets/palette_light_amber.dart';
import 'package:chain_activities/widgets/redirect.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/first_boot_screen.dart';
import 'package:chain_activities/screens/load_screen.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:chain_activities/screens/play_wait_activity_screen.dart';
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
      title: 'ChainPlay',
      builder: (context, widget) {
        Widget error = const Scaffold(body: Center(child: MyErrorWidget()));
        ErrorWidget.builder = (errorDetails) => error;
        if (widget != null) {
          return widget;
          // return MediaQuery(
          //   data: MediaQuery.of(context)
          //       .copyWith(textScaler: const TextScaler.linear(1.0)),
          //   child: widget,
          // );
        }
        throw ('widget is null');
      },
      //darkTheme: darkTheme ? ThemeData.dark() : null,
      debugShowCheckedModeBanner: false,
      theme: darkTheme
          ? ThemeData(
              // useMaterial3: false,
              primarySwatch: PaletteDark.lightGrey,
              scaffoldBackgroundColor: PaletteDark.lightGrey.shade900,
              cardColor: PaletteDark.lightGrey.shade800,
              canvasColor: PaletteDark.lightGrey,
              colorScheme: ColorScheme.dark(
                surface: PaletteDark.lightGrey,
                primary: PaletteDark.lightGrey.shade700,
                onPrimary: Colors.amber,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => PaletteDark.lightGrey,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => Colors.amber,
                  ),
                  textStyle: WidgetStateProperty.resolveWith(
                    (states) => Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              listTileTheme: ListTileThemeData(
                tileColor: PaletteDark.lightGrey,
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return PaletteDark.lightGrey;
                    } else {
                      return Colors.grey;
                    }
                  },
                ),
                trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.grey;
                  } else {
                    return PaletteDark.lightGrey;
                  }
                }),
              ),
              drawerTheme: DrawerThemeData(
                backgroundColor: PaletteDark.lightGrey,
              ),
              dividerTheme: DividerThemeData(
                color: PaletteDark.lightGrey.shade700,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: PaletteDark.lightGrey,
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: PaletteDark.lightGrey.shade700,
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.grey.withValues(alpha: 0.5),
                cursorColor: Colors.amber,
                selectionHandleColor: Colors.grey,
              ),
              snackBarTheme: const SnackBarThemeData(
                actionTextColor: Colors.amber,
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
              dialogTheme: DialogThemeData(
                  backgroundColor: PaletteDark.lightGrey.shade800),
            )
          : ThemeData(
              // useMaterial3: false,
              primarySwatch: PaletteLigthAmber.ligthAmber,
              scaffoldBackgroundColor: Colors.white,
              cardColor: PaletteLigthAmber.ligthAmber.shade300,
              canvasColor: PaletteLigthAmber.ligthAmber.shade100,
              colorScheme: ColorScheme.light(
                surface: PaletteLigthAmber.ligthAmber,
                primary: PaletteLigthAmber.ligthAmber.shade100,
                onPrimary: Colors.black,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => Colors.white),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => Colors.black,
                  ),
                  textStyle: WidgetStateProperty.resolveWith(
                    (states) => Theme.of(context).textTheme.labelLarge,
                  ),
                  iconColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => Colors.black,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => PaletteLigthAmber.ligthAmber.shade100),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => Colors.black,
                  ),
                  textStyle: WidgetStateProperty.resolveWith(
                    (states) => Theme.of(context).textTheme.labelLarge,
                  ),
                  iconColor: WidgetStateProperty.resolveWith<Color>(
                    (states) => Colors.black,
                  ),
                ),
              ),

              listTileTheme: ListTileThemeData(
                tileColor: Colors.white,
              ),
              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    } else {
                      return PaletteLigthAmber.ligthAmber;
                    }
                  },
                ),
                trackColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return PaletteLigthAmber.ligthAmber;
                  } else {
                    return Colors.white;
                  }
                }),
              ),

              drawerTheme: DrawerThemeData(
                backgroundColor: Colors.white,
              ),
              dividerTheme: DividerThemeData(
                color: PaletteLigthAmber.ligthAmber.shade200,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.white,
              ),
              inputDecorationTheme: InputDecorationTheme(
                fillColor: PaletteLigthAmber.ligthAmber.shade200,
              ),
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: PaletteLigthAmber.ligthAmber.shade400,
                cursorColor: Colors.black,
                selectionHandleColor: PaletteLigthAmber.ligthAmber,
              ),
              snackBarTheme: const SnackBarThemeData(
                actionTextColor: Colors.white,
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
              dialogTheme: DialogThemeData(
                backgroundColor: Colors.white,
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
        FirstBootScreen.routename: (context) => const FirstBootScreen(),
        ViewChain.routename: (context) => const ViewChain(),
        ViewChainTutorial.routename: (context) => const ViewChainTutorial(),
        PixabaySelectionScreen.routename: (context) =>
            const PixabaySelectionScreen(),
      },
    );
  }
}
