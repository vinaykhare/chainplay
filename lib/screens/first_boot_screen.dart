import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/tutorial/screens/chain_list_screen_tutorial.dart';

import 'package:chain_activities/widgets/db_settings.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:provider/provider.dart';

class FirstBootScreen extends StatefulWidget {
  static String routename = "/firstbootscreen";
  const FirstBootScreen({super.key});

  @override
  State<FirstBootScreen> createState() => _FirstBootScreenState();
}

class _FirstBootScreenState extends State<FirstBootScreen> {
  // bool pdfView = false;

  late ChainList chainList;
  bool initConfig = true;

  // @override
  // void dispose() {
  //   super.dispose();
  //   chainList.dontShowHelpOnNextLoad();
  // }

  @override
  Widget build(BuildContext context) {
    if (initConfig) {
      chainList = Provider.of<ChainList>(context, listen: false);
      // chainList.showHelpOnNextLoad();
      //  chainList.loadSampleChainsForTutorial();
      initConfig = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        // (appBarWidget.preferredSize.height * 1) -
        MediaQuery.of(context).viewPadding.top;

    return Semantics(
      label: "Help Screen to guide how it works",
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(5),
            child: Card(
              elevation: 10,
              color: Theme.of(context).primaryColor,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(children: [
                        Image.asset(
                          assetMap["logoImage"]!,
                          height: appHeight * 0.40,
                        ),
                        Text(
                          "ChainPlay",
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Chain the Activities and Play it",
                          style: Theme.of(context).textTheme.labelLarge,
                          textAlign: TextAlign.center,
                        ),
                      ])),
                  Text(
                    "Set Preferences",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Expanded(child: DbSettings()),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.home,
                        size: 35,
                      ),
                      onPressed: () async {
                        NavigatorState nav = Navigator.of(context);
                        //await chainList.dontShowHelpOnNextLoad();
                        await chainList.setSetting(
                            showHelpOnNextBootKey, falseSettingValue);
                        await chainList.stopSpeech();
                        await chainList.loadSampleChainsForTutorial();
                        nav.pushReplacementNamed(
                            ChainListScreenTutorial.routename);
                      },
                      label: const Text("Let's Chain & Play!"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
