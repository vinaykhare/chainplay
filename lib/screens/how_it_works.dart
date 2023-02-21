import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class HowItWorks extends StatelessWidget {
  static String routename = "/howitworks";
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: PdfViewer.openAsset(assetMap['howItWorksPDF']!),
            ),
            AppBar(
              centerTitle: true,
              title: const Text("How CAT Works??"),
            ),
          ],
        ),
      ),
    );
  }
}
