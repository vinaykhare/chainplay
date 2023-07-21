import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/widgets/cat_container.dart';
import 'package:chain_activities/widgets/chain_list_header.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';
import 'package:chain_activities/widgets/clock.dart';
import 'package:chain_activities/widgets/home_button_widget.dart';
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
  bool showChainControlSummary = true;
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
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.all(2.0),
      //     child: FloatingActionButton(
      //       elevation: 10,
      //       key: addChainKey,
      //       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //       onPressed: () {
      //         Navigator.of(context)
      //             .pushReplacementNamed(AddChainScreen.routename);
      //       },
      //       child: Image.asset(
      //         assetMap["logoImage"]!,
      //         height: 50,
      //       ),
      //     ),
      //   )
      // ],
      //automaticallyImplyLeading: false,
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
          //mainAxisSize: MainAxisSize.min,
          children: [
            // const Padding(
            //   padding: EdgeInsets.only(
            //     top: 5,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: CatContainer(
                //key: ValueKey("Clock"),
                key: titleClockKey,
                childWidget: const Clock(),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(AddChainScreen.routename);
                },
                catContainerTitle: "Chain the Activities with Timers",
                helpText: "Tap Clock to Create a Scheduled Chain | Alarm",
                catContainerIcon: Container(
                  key: addChainKey,
                  child: Image.asset(
                    assetMap["logoImage"]!,
                    height: 50,
                  ),
                ),
              ),
            ),
            // if (chains.isNotEmpty) //showHelp
            // Container(
            //   width: double.infinity,
            //   margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            //   padding: const EdgeInsets.only(bottom: 8),
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).primaryColor,
            //     borderRadius: const BorderRadius.all(Radius.circular(30)),
            //   ),
            //   child: const ChainTileHelp(),
            // ),
            if (chains.isNotEmpty)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ChainListHeader(),
                      // Divider(
                      //   color: Theme.of(context).primaryColorLight,
                      // ),
                      Expanded(
                        child: ReorderableListView.builder(
                          //reverse: true,
                          onReorder: (oldIndex, newIndex) =>
                              Provider.of<ChainList>(context, listen: false)
                                  .rearrangeChains(oldIndex, newIndex),
                          itemCount: chains.length,
                          itemBuilder: (context, index) {
                            Chain chain = chains[index];
                            //BannerAd? adChain = chain.adBanner;
                            return ChainListItem(
                              //adChain: adChain,
                              chain: chain,
                              showHistory: true,
                              allowFlag: true,
                              key: Key(
                                index.toString(),
                              ),
                              index: index,
                            );
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            showChainControlSummary = !showChainControlSummary;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Text(
                            "Summary of Chain Controls",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (showChainControlSummary)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          padding: const EdgeInsets.only(bottom: 8),
                          // decoration: BoxDecoration(
                          //   color: Theme.of(context).primaryColor,
                          //   border: Border.all(
                          //     width: 1,
                          //     color: Theme.of(context).scaffoldBackgroundColor,
                          //   ),
                          // ),
                          child: const ChainTileHelp(),
                        ),
                    ],
                  ),
                ),
              ),
            if (chains.isEmpty)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No Chains to Play or Schedule",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      HomeButtonWidget(
                        chainListFunction: "loadSampleChains",
                        buttonText: "Add \n'Sample Chain of Timers'",
                        logo: Icon(
                          Icons.web_stories,
                          size: 50,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      HomeButtonWidget(
                        chainListFunction: "navigateToAddChainScreen",
                        buttonText: "Create\nYour Own Chain of Timers.",
                        logo: Icon(
                          Icons.create_outlined,
                          size: 50,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      HomeButtonWidget(
                        chainListFunction: "navigateToHelpScreen",
                        buttonText: "Know\nmore about Chains (CAT).",
                        logo: Icon(
                          Icons.help,
                          size: 50,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ],
                  ),
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
