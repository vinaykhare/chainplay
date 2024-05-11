import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/tutorial/screens/how_it_works.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeButtonWidget extends StatelessWidget {
  final String buttonText, chainListFunction;
  final Widget logo;
  const HomeButtonWidget({
    super.key,
    required this.buttonText,
    required this.chainListFunction,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor.withOpacity(0.7),
      ),
      child: TextButton(
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
              Navigator.of(context).pushReplacementNamed(HowItWorks.routename);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                child: logo,
              ),
              Text(
                buttonText,
                //textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
