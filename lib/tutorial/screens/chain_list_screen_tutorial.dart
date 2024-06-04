import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/tutorial/tutorial_coach.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/tutorial/widgets/chain_list_header_tutorial.dart';
import 'package:chain_activities/tutorial/widgets/list_of_chains_tutorial.dart';
import 'package:chain_activities/widgets/no_chains_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
//import 'package:chain_activities/widgets/app_drawer.dart';

class ChainListScreenTutorial extends StatefulWidget {
  static String routename = "/chains_tutorial";

  const ChainListScreenTutorial({super.key});

  @override
  State<ChainListScreenTutorial> createState() =>
      _ChainListScreenTutorialState();
}

class _ChainListScreenTutorialState extends State<ChainListScreenTutorial> {
  late ChainList chainList;
  late TutorialCoach tutorialCoach;
  bool pageInit = true;

  // void showTutorial() {
  //   tutorialCoach.showTutorial(context);
  // }

  // late ChainList chainList;
  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      chainList = Provider.of<ChainList>(context, listen: true);
      TutorialCoach tutorialCoach = TutorialCoach(
        chainList: chainList,
        tutorialType: showHelpOnNextBootKey,
      );
      tutorialCoach.createTutorial(context);
      chainList.speakText("This is the App's header with a couple of Buttons.");
      tutorialCoach.showTutorial(context);
      pageInit = false;
    }
    List<Chain> chains = chainList.chains;

    final appBarWidget = AppBar(
      key: KeyHelper.chianListScreenAppBarkey,
      centerTitle: true,
      title: TextField(
        key: KeyHelper.chianListSearchkey,
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
            //borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
          ),
          //fillColor: Theme.of(context).primaryColor.withGreen(200),
        ),
      ),
    );
    // double appHeight =
    //     MediaQuery.of(context).size.height - appBarWidget.preferredSize.height;
    return Semantics(
      label: "Home Screen Tutorial with list of chains and other options.",
      child: Scaffold(
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                margin: const EdgeInsets.all(10),
                child: const ChainListHeaderTutorial(),
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
                  child: Column(
                    children: [
                      (chains.isNotEmpty)
                          ? const Expanded(child: ListOfChainsTutorial())
                          : const Expanded(child: NoChainsView()),
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
      ),
    );
  }
}
