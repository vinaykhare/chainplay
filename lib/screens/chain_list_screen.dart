import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/helpers/tutorial_coach.dart';
import 'package:chain_activities/models/system_setting.dart';
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

class ChainListScreen extends StatefulWidget {
  static String routename = "/chains";

  const ChainListScreen({super.key});

  @override
  State<ChainListScreen> createState() => _ChainListScreenState();
}

class _ChainListScreenState extends State<ChainListScreen> {
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
      SystemSetting showHomeScreenTutorialSetting =
          chainList.getSettingByKey(showHomeScreenTutorialKey);
      if (showHomeScreenTutorialSetting.value.isEmpty ||
          showHomeScreenTutorialSetting.value == trueSettingValue) {
        TutorialCoach tutorialCoach = TutorialCoach(
          chainList: chainList,
          tutorialType: showHomeScreenTutorialKey,
        );
        tutorialCoach.createTutorial(context);
        chainList.speakText(
            "Header of CAT App contains its Logo with Couple of most frequently used buttons.");
        tutorialCoach.showTutorial(context);
      }
      pageInit = false;
    }
    List<Chain> chains = chainList.chains;

    final appBarWidget = AppBar(
      centerTitle: true,
      title: TextField(
        key: KeyHelper.searchChainKey,
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
      label: "Home Screen with list of chains and other options.",
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
                  child: Column(
                    children: [
                      (chains.isNotEmpty)
                          ? const Expanded(child: ListOfChains())
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
