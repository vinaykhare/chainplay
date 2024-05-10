import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/tutorial/widgets/help_header.dart';
import 'package:chain_activities/tutorial/widgets/skip_button.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';
// import 'package:provider/provider.dart';

class HowItWorks extends StatefulWidget {
  static String routename = "/howitworks";
  const HowItWorks({super.key});

  @override
  State<HowItWorks> createState() => _HowItWorksState();
}

class _HowItWorksState extends State<HowItWorks> {
  // bool pdfView = false;

  late ChainList chainList;

  @override
  void initState() {
    super.initState();
    chainList = Provider.of<ChainList>(context, listen: false);
    // chainList.showHelpOnNextLoad();
    chainList.loadSampleChainsFromAssets();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   chainList.dontShowHelpOnNextLoad();
  // }

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height -
        // (appBarWidget.preferredSize.height * 1) -
        MediaQuery.of(context).viewPadding.top;

    double appWidth = MediaQuery.of(context).size.width - 16;
    return Semantics(
      label: "Help Screen to guide how it works",
      child: Scaffold(
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              HelpHeader(
                appHeight: appHeight,
                appWidth: appWidth,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SkipButton(
                    onPressed: () async {
                      NavigatorState nav = Navigator.of(context);
                      //await chainList.dontShowHelpOnNextLoad();
                      await chainList.setSetting(
                          showHelpOnNextBootKey, falseSettingValue);
                      await chainList.stopSpeech();
                      nav.pushReplacementNamed(ChainListScreen.routename);
                    },
                  ),
                  // child: IconButton(
                  //   icon: const Icon(
                  //     Icons.cancel,
                  //     size: 35,
                  //   ),
                  //   onPressed: () async {
                  //     NavigatorState nav = Navigator.of(context);
                  //     //await chainList.dontShowHelpOnNextLoad();
                  //     await chainList.setSetting(
                  //         showHelpOnNextBootKey, falseSettingValue);
                  //     await chainList.stopSpeech();
                  //     nav.pushReplacementNamed(ChainListScreen.routename);
                  //   },
                  // ),
                ), //appBarWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
