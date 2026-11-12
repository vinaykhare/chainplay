import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_list.dart';

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
  bool initConfig = true, addSampleChains = true;

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
      addSampleChains =
          chainList.getSettingByKey(addSampleChainsOnBootSettingKey).value !=
              falseSettingValue;
      initConfig = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        // (appBarWidget.preferredSize.height * 1) -
        MediaQuery.of(context).viewPadding.top;

    final Widget header = Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(children: [
        Image.asset(
          assetMap["logoImage"]!,
          height: appHeight * 0.20,
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
      ]),
    );

    // Both orientations get the same widgets. In landscape there is not enough
    // height for the fixed header, heading and button around the setting list,
    // so the whole card scrolls and nothing overflows.
    final Widget preferences = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Set Preferences",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(
              child: Text(
                "Add Sample Chains at Start",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Switch(
              value: addSampleChains,
              onChanged: (value) async {
                setState(() {
                  addSampleChains = value;
                });
                await chainList.setSetting(
                  addSampleChainsOnBootSettingKey,
                  value ? trueSettingValue : falseSettingValue,
                  settingDataTypeBool,
                );
              },
            )
          ]),
        ),
        // SwitchListTile(
        //   value: addSampleChains,
        //   onChanged: (value) async {
        //     setState(() {
        //       addSampleChains = value;
        //     });
        //     await chainList.setSetting(
        //       addSampleChainsOnBootSettingKey,
        //       value ? trueSettingValue : falseSettingValue,
        //       settingDataTypeBool,
        //     );
        //   },
        //   title: Text(
        //     "Add Sample Chains at Start",
        //     style: Theme.of(context).textTheme.titleMedium,
        //   ),
        //   subtitle: Text(
        //     "Three example chains to try the controls. Swipe them away any time.",
        //     style: Theme.of(context).textTheme.labelSmall,
        //   ),
        // ),
        const SizedBox(height: 150, child: DbSettings()),
      ],
    );

    final Widget startapp = Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton.icon(
        icon: const Icon(
          Icons.home,
          size: 35,
        ),
        onPressed: () async {
          if (addSampleChains) {
            await chainList.loadSampleChainsFromAssets();
          }
          await chainList.setSetting(showHelpOnNextBootKey, falseSettingValue);
        },
        label: const Text("Let's Chain & Play!"),
      ),
    );

    return Semantics(
      label: "Help Screen to guide how it works",
      child: Scaffold(
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(5),
            child: Card(
              elevation: 10,
              color: Theme.of(context).primaryColor,
              child: OrientationBuilder(builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                          children: [
                            header,
                            startapp,
                          ],
                        )),
                        Expanded(child: preferences),
                      ],
                    ),
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    header,
                    Expanded(
                      child: SingleChildScrollView(child: preferences),
                    ),
                    startapp,
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
