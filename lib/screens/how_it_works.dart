import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/models/system_setting.dart';
import 'package:chain_activities/widgets/help_header.dart';
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
  void dispose() {
    super.dispose();
    dontShowHelpOnNextLoad();
  }

  Future<bool> dontShowHelpOnNextLoad() async {
    List<SystemSetting> systemSettings = chainList.systemSettings;
    int showHelpEntryIndex = systemSettings.indexWhere(
      (set) => set.key == "Show help on next boot",
    );

    if (showHelpEntryIndex != -1 &&
        systemSettings[showHelpEntryIndex].value == "TRUE") {
      systemSettings[showHelpEntryIndex].value == "FALSE";
      await chainList.setSetting(
        "Show help on next boot",
        "FALSE",
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    chainList = Provider.of<ChainList>(context, listen: false);
    final appBarWidget = AppBar(
      centerTitle: true,
      title: const Text("How CAT Works??"),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Column(
      //       children: [
      //         const Text("Detailed View?"),
      //         Expanded(
      //           child: Switch(
      //             value: pdfView,
      //             onChanged: (value) {
      //               setState(() {
      //                 pdfView = value;
      //               });
      //             },
      //           ),
      //         ),
      //       ],
      //     ),
      //   )
      // ],
    );
    double appHeight = MediaQuery.of(context).size.height -
        (appBarWidget.preferredSize.height * 1) -
        MediaQuery.of(context).viewPadding.top;

    double appWidth = MediaQuery.of(context).size.width - 16;
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   title: const Text("How CAT Works??"),
      // ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // if (pdfView)
            //   Expanded(child: PdfViewer.openAsset(assetMap['howItWorksPDF']!))
            // else
            Expanded(
              child: HelpHeader(
                appHeight: appHeight,
                appWidth: appWidth,
              ),
            ),
            appBarWidget,
          ],
        ),
      ),
    );
  }
}
