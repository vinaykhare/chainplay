import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/tutorial/screens/chain_list_screen_tutorial.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeButtonWidget extends StatelessWidget {
  final String buttonText, chainListFunction, buttonSubText;
  final Widget logo;
  const HomeButtonWidget({
    super.key,
    required this.buttonText,
    required this.chainListFunction,
    required this.logo,
    required this.buttonSubText,
  });

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(bottom: 5),
      child: ElevatedButton(
        onPressed: () async {
          switch (chainListFunction) {
            case "loadSampleChains":
              await chainList.loadSampleChainsFromAssets();
              break;
            case "navigateToAddChainScreen":
              Navigator.of(context)
                  .pushReplacementNamed(AddChainScreen.routename);
              break;
            case "navigateToHelpScreen":
              NavigatorState nav = Navigator.of(context);
              await chainList.loadSampleChainsForTutorial();
              nav.pushReplacementNamed(ChainListScreenTutorial.routename);
              break;
            case "uploadChain":
              NavigatorState nav = Navigator.of(context);
              ChainList chainList =
                  Provider.of<ChainList>(context, listen: false);
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ["json"],
              );

              if (result != null) {
                Chain? chain =
                    await chainList.uploadChain(result.files.single.path!);
                nav.pushNamed(
                  ViewChain.routename,
                  arguments: {
                    "chain": chain ?? Chain(),
                    "savedInDb": chain == null,
                    "invalidChain": chain == null,
                  },
                );
              } else {
                // User canceled the picker
              }
              break;
          }
        },
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                child: logo,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buttonText,
                    //textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                  Text(
                    buttonSubText,
                    //textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).unselectedWidgetColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
