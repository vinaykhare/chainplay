import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:schedule_it/widgets/app_drawer.dart';

class HowItWorks extends StatefulWidget {
  static String routename = "/howitworks";
  const HowItWorks({super.key});

  @override
  State<HowItWorks> createState() => _HowItWorksState();
}

class _HowItWorksState extends State<HowItWorks> {
  static const int _initialPage = 2;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  bool isSampleDoc = true;
  late PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/help/howitworks.pdf'),
      initialPage: _initialPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pdfController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("How Schedule It Works??"),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PdfViewPinch(
                documentLoader:
                    const Center(child: CircularProgressIndicator()),
                pageLoader: const Center(child: CircularProgressIndicator()),
                controller: _pdfController,
                onDocumentLoaded: (document) {
                  setState(() {
                    _allPagesCount = document.pagesCount;
                  });
                },
                onPageChanged: (page) {
                  setState(() {
                    _actualPageNumber = page;
                  });
                },
              ),
            ),
            AppBar(
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed: () {
                      _pdfController.previousPage(
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 100),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '$_actualPageNumber/$_allPagesCount',
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed: () {
                      _pdfController.nextPage(
                        curve: Curves.ease,
                        duration: const Duration(milliseconds: 100),
                      );
                    },
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.refresh),
                  //   onPressed: () {
                  //     if (isSampleDoc) {
                  //       _pdfController.loadDocument(PdfDocument.openAsset(
                  //           'assets/help/howitworks.pdf'));
                  //     } else {
                  //       _pdfController.loadDocument(PdfDocument.openAsset(
                  //           'assets/help/howitworks.pdf'));
                  //     }
                  //     isSampleDoc = !isSampleDoc;
                  //   },
                  // )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
