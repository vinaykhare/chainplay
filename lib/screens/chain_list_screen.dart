import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/widgets/cat_container.dart';
import 'package:chain_activities/widgets/clock.dart';
import 'package:chain_activities/widgets/home_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
//import 'package:chain_activities/widgets/app_drawer.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ChainListScreen extends StatefulWidget {
  static String routename = "/chains";

  const ChainListScreen({super.key});

  @override
  State<ChainListScreen> createState() => _ChainListScreenState();
}

class _ChainListScreenState extends State<ChainListScreen> {
  bool showHelp = true;
  late TutorialCoachMark tutorialCoachMark;
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
            align: ContentAlign.top,
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
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
      },
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  @override
  void initState() {
    super.initState();

    createTutorial();
    Future.delayed(Duration.zero, showTutorial);
  }

  // late ChainList chainList;
  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    List<Chain> chains = chainList.chains;

    final appBarWidget = AppBar(
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: FloatingActionButton(
            key: addChainKey,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(AddChainScreen.routename);
            },
            child: const Icon(Icons.add),
          ),
        )
      ],
      //automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
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
          ),
        ],
      ),
    );
    double appHeight =
        MediaQuery.of(context).size.height - appBarWidget.preferredSize.height;
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
            CatContainer(
              //key: ValueKey("Clock"),
              key: titleClockKey,
              childWidget: const Clock(),
              containerTitle: "\t\tChain the Alarms & Timers",
              helpText: "Tap this Clock to Create a Scheduled Chain.",
            ),
            Expanded(
              child: CatContainer(
                key: chainsKey,
                onPressed: () {
                  setState(() {
                    showHelp = !showHelp;
                  });
                },
                containerTitle: chains.isEmpty
                    ? "Oops, No Chains!"
                    : "All Chains, of Alarms & Timers",
                childWidget: SizedBox(
                  // height: chains.isNotEmpty && chains.length <= 3
                  //     ? appHeight * 0.4
                  //     : appHeight * 0.59,
                  //height: appHeight * (showHelp ? 0.45 : 0.59),
                  height: appHeight * 0.60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: chains.isNotEmpty
                              ? ReorderableListView.builder(
                                  //reverse: true,
                                  onReorder: (oldIndex, newIndex) =>
                                      Provider.of<ChainList>(context,
                                              listen: false)
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
                                )
                              : ListView(
                                  children: [
                                    HomeButtonWidget(
                                      chainListFunction: "loadSampleChains",
                                      buttonText:
                                          "Add \n'Sample Chain of Timers'",
                                      logo: Icon(
                                        Icons.account_box,
                                        size: 50,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    HomeButtonWidget(
                                      chainListFunction:
                                          "navigateToAddChainScreen",
                                      buttonText:
                                          "Create\nYour Own Chain of Timers.",
                                      logo: Icon(
                                        Icons.create_outlined,
                                        size: 50,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                    HomeButtonWidget(
                                      chainListFunction: "navigateToHelpScreen",
                                      buttonText:
                                          "Know\nmore about Chains (CAT).",
                                      logo: Icon(
                                        Icons.help,
                                        size: 50,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (showHelp)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                          ),
                          child: const ChainTileHelp(),
                        )
                    ],
                  ),
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
