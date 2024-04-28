import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/tutorial/screens/chain_list_screen_tutorial.dart';
import 'package:chain_activities/tutorial/widgets/help_header.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:provider/provider.dart';

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
    chainList.showHelpOnNextLoad();
  }

  @override
  void dispose() {
    super.dispose();
    chainList.dontShowHelpOnNextLoad();
  }

  // Future<bool> dontShowHelpOnNextLoad() async {
  //   List<SystemSetting> systemSettings = chainList.systemSettings;
  //   int showHelpEntryIndex = systemSettings.indexWhere(
  //     (set) => set.key == showHelpOnNextBootKey,
  //   );

  //   if (showHelpEntryIndex != -1 &&
  //       systemSettings[showHelpEntryIndex].value == trueSettingValue) {
  //     systemSettings[showHelpEntryIndex].value == falseSettingValue;
  //     await chainList.setSetting(
  //       showHelpOnNextBootKey,
  //       falseSettingValue,
  //     );
  //   }
  //   return true;
  // }

  // final appBarWidget = AppBar(
  //   backgroundColor: Theme.of(context).dialogBackgroundColor,
  //   centerTitle: true,
  //   automaticallyImplyLeading: false,
  //   title: ListTile(
  //     title: ElevatedButton(
  //       onPressed: () {
  //         Navigator.of(context)
  //             .pushReplacementNamed(ChainListScreen.routename);
  //       },
  //       style: ElevatedButton.styleFrom(
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(30.0)),
  //         backgroundColor: Theme.of(context).primaryColor,
  //         textStyle: Theme.of(context).textTheme.labelLarge,
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Image.asset(
  //             assetMap["logoImage"]!,
  //             height: 50,
  //           ),
  //           Expanded(
  //             child: Text(
  //               "SKIP Introduction \n& Go Home",
  //               textAlign: TextAlign.center,
  //               style: Theme.of(context).textTheme.titleLarge,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),

  //   // actions: [
  //   //   Padding(
  //   //     padding: const EdgeInsets.all(8.0),
  //   //     child: Column(
  //   //       children: [
  //   //         const Text("Detailed View?"),
  //   //         Expanded(
  //   //           child: Switch(
  //   //             value: pdfView,
  //   //             onChanged: (value) {
  //   //               setState(() {
  //   //                 pdfView = value;
  //   //               });
  //   //             },
  //   //           ),
  //   //         ),
  //   //       ],
  //   //     ),
  //   //   )
  //   // ],
  // );

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height -
        // (appBarWidget.preferredSize.height * 1) -
        MediaQuery.of(context).viewPadding.top;

    double appWidth = MediaQuery.of(context).size.width - 16;
    return Semantics(
      label: "Help Screen to guide how it works",
      child: Scaffold(
        // appBar: AppBar(
        //   centerTitle: true,
        //   automaticallyImplyLeading: false,
        //   title: const Text("How CAT Works??"),
        // ),
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              // if (pdfView)
              //   Expanded(child: PdfViewer.openAsset(assetMap['howItWorksPDF']!))
              // else
              HelpHeader(
                appHeight: appHeight,
                appWidth: appWidth,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      size: 35,
                    ),
                    onPressed: () async {
                      NavigatorState nav = Navigator.of(context);
                      //await chainList.dontShowHelpOnNextLoad();
                      await chainList.stopSpeech();
                      nav.pushReplacementNamed(
                          ChainListScreenTutorial.routename);
                    },
                  ),
                ), //appBarWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
