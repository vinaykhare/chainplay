import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/tutorial/tutorial_coach.dart';
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

  @override
  Widget build(BuildContext context) {
    if (pageInit) {
      chainList = Provider.of<ChainList>(context, listen: true);
      TutorialCoach tutorialCoach = TutorialCoach(
        chainList: chainList,
        tutorialType: showHelpOnNextBootKey,
      );
      tutorialCoach.createTutorial(context);
      chainList.speakText(
          "This is the App's header with a Logo and Couple of Buttons to the right. Now press on the highlighted section over this and the following screens to move to the next slide of this tutorial.");
      tutorialCoach.showTutorial(context);
      pageInit = false;
    }
    List<Chain> chains = chainList.chains;

    final appBarWidget = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      key: KeyHelper.chainListScreenAppBarkey,
      centerTitle: true,
      title: TextField(
        key: KeyHelper.chainListSearchkey,
        keyboardType: TextInputType.none,
        cursorColor: Theme.of(context).cardColor,
        showCursor: false,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          label: const Text("Search Chains"),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
      // actions: [
      //   IconButton(
      //     key: KeyHelper.chainFiltersKey,
      //     onPressed: () {},
      //     icon: Icon(
      //       Icons.favorite_outline,
      //     ),
      //   ),
      // ],
    );
    return IgnorePointer(
      ignoring: true,
      child: Semantics(
        label: "Home Screen Tutorial with list of chains and other options.",
        child: Scaffold(
          drawer: const AppDrawer(),
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ChainListHeaderTutorial(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        (chains.isNotEmpty)
                            ? const Expanded(
                                child: ListOfChainsTutorial(
                                  textFilter: null,
                                  showAd: true,
                                  showChainControlSummary: true,
                                  showChainInReverse: false,
                                  showFavorites: false,
                                  showRunning: false,
                                ),
                              )
                            : const Expanded(child: NoChainsView()),
                      ],
                    ),
                  ),
                ),
                appBarWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
