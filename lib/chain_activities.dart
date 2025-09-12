import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/helpers/theme_factory.dart';
import 'package:chain_activities/screens/pixabay_selection_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/tutorial/screens/play_wait_activity_screen_tutorial.dart';
import 'package:chain_activities/widgets/my_error_widget.dart';
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
      (set) => set.key == themeSettingKey,
    );

    String chosenTheme = themeIndex == -1
        ? themeAmber
        : chainList.systemSettings[themeIndex].value.split(",").first;
    // bool darkTheme = themeIndex == -1
    //     ? false
    //     : chainList.systemSettings[themeIndex].value == trueSettingValue;
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
      theme: ThemeFactory().getTheme(context, chosenTheme),
      // theme:
      //     ThemeFactory().getTheme(context, darkTheme ? themeBlack : themeAmber),
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
        SearchChainScreen.routename: (context) => const SearchChainScreen(),
        SettingsScreen.routename: (context) => const SettingsScreen(),
        PlayWaitActivity.routename: (context) => const PlayWaitActivity(),
        PlayWaitActivityScreenTutorial.routename: (context) =>
            const PlayWaitActivityScreenTutorial(),
        LoadScreen.routename: (context) => const LoadScreen(),
        FirstBootScreen.routename: (context) => const FirstBootScreen(),
        ViewChain.routename: (context) => const ViewChain(),
        PixabaySelectionScreen.routename: (context) =>
            const PixabaySelectionScreen(),
      },
    );
  }
}
