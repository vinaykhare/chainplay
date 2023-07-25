import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/widgets/chain_list_header.dart';
import 'package:chain_activities/widgets/list_of_chains.dart';
import 'package:chain_activities/widgets/no_chains_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
//import 'package:chain_activities/widgets/app_drawer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ChainListScreen extends StatefulWidget {
  static String routename = "/chains";

  const ChainListScreen({super.key});

  @override
  State<ChainListScreen> createState() => _ChainListScreenState();
}

class _ChainListScreenState extends State<ChainListScreen> {
  late TutorialCoachMark tutorialCoachMark;
  late ChainList chainList;
  GlobalKey titleClockKey = GlobalKey();
  GlobalKey chainsKey = GlobalKey();
  GlobalKey addChainKey = GlobalKey();

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "titleClockKey",
        keyTarget: titleClockKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                children: [
                  const Text(
                    "CAT Clock.",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    child: const Text("Next"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "chainsKey",
        keyTarget: chainsKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                children: [
                  const Text(
                    "All Chains",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    child: const Text("Next"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "addChainKey",
        keyTarget: addChainKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                children: [
                  const Text(
                    "Add Chain.",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.next(),
                    child: const Text("Next"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black,
      //textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      //imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      alignSkip: Alignment.bottomCenter,
      skipWidget: const Card(
        elevation: 30,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Skip",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onFinish: () {
        chainList.dontShowHelpOnNextLoad();
      },
      // onClickTarget: (target) {
      //   print('onClickTarget: $target');
      // },
      // onClickTargetWithTapPosition: (target, tapDetails) {
      //   print("target: $target");
      //   print(
      //       "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      // },
      // onClickOverlay: (target) {
      //   print('onClickOverlay: $target');
      // },
      onSkip: () {
        chainList.dontShowHelpOnNextLoad();
      },
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  @override
  void initState() {
    super.initState();
    chainList = Provider.of<ChainList>(context, listen: false);
    if (chainList.getSettingByKey(showHelpOnNextBootKey).value ==
        trueSettingValue) {
      createTutorial();
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  // late ChainList chainList;
  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    List<Chain> chains = chainList.chains;

    final appBarWidget = AppBar(
      centerTitle: true,
      title: TextField(
        keyboardType: TextInputType.none,
        cursorColor: Theme.of(context).cardColor,
        showCursor: false,
        onTap: () =>
            Navigator.of(context).pushNamed(SearchChainScreen.routename),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          label: const Text("Search Chains"),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
    // double appHeight =
    //     MediaQuery.of(context).size.height - appBarWidget.preferredSize.height;
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // margin: const EdgeInsets.symmetric(
              //   vertical: 10,
              // ),
              margin: const EdgeInsets.all(10),
              child: const ChainListHeader(),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: (chains.isNotEmpty)
                    ? const ListOfChains()
                    : const NoChainsView(),
              ),
            ),
            appBarWidget,
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).pushNamed(AddChainScreen.routename);
      //   },
      //   child: const Icon(
      //     Icons.add,
      //   ),
      // ),
    );
  }
}
