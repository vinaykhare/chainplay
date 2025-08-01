import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOfChainsTutorial extends StatefulWidget {
  final String? textFilter;
  final bool showFavorites, showRunning;
  final bool? showChainControlSummary, showAd, showChainInReverse;
  const ListOfChainsTutorial({
    super.key,
    this.textFilter,
    this.showChainControlSummary,
    this.showAd,
    this.showChainInReverse,
    required this.showFavorites,
    required this.showRunning,
  });

  @override
  State<ListOfChainsTutorial> createState() => _ListOfChainsTutorialState();
}

class _ListOfChainsTutorialState extends State<ListOfChainsTutorial> {
  bool showChainControlSummary = true;
  List<Chain> allChains = [], activeChains = [], favoriteChains = [];
  late ChainList chainList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // ChainList chainList = Provider.of<ChainList>(context, listen: true);

    bool showFavorites = widget.showFavorites, showRunning = widget.showRunning;
    Chain? sampleWorkoutChain, sampleDietChain, sampleMedicineChain;
    List<Chain> chains = chainList.getChainsByFilters(
        "Sample Workout Chain", showFavorites, showRunning);
    if (chains.isNotEmpty) {
      sampleWorkoutChain = chains[0];
    }
    chains = chainList.getChainsByFilters(
        "Sample Diet Routine Chain", showFavorites, showRunning);
    if (chains.isNotEmpty) {
      sampleDietChain = chains[0];
    }
    chains = chainList.getChainsByFilters(
        "Sample Medicine Routine Chain", showFavorites, showRunning);
    if (chains.isNotEmpty) {
      sampleMedicineChain = chains[0];
    }
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showChainControlSummary == null ||
            widget.showChainControlSummary == true)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  key: KeyHelper.chainControlSummaryKey,
                  icon: Icon(Icons.help),
                  onPressed: () {
                    setState(() {
                      showChainControlSummary = !showChainControlSummary;
                    });
                  },
                ),
                Row(
                  key: KeyHelper.chainFiltersKey,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showFavorites = false;
                          showRunning = false;
                        });
                      },
                      child: Text(
                        "All Chains",
                        style: TextStyle(
                          fontWeight:
                              showFavorites == false && showRunning == false
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showRunning = true;
                          showFavorites = false;
                        });
                      },
                      child: Text(
                        "Running Chains",
                        style: TextStyle(
                          fontWeight:
                              showFavorites == false && showRunning == true
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showFavorites = true;
                          showRunning = false;
                        });
                      },
                      child: Text(
                        "Favorite Chains",
                        style: TextStyle(
                          fontWeight:
                              showFavorites == true && showRunning == false
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(),
              ],
            ),
          ),
        Column(
          key: KeyHelper.chainListKey,
          children: [
            if (sampleWorkoutChain != null)
              ChainListItem(
                tutorialChain: sampleWorkoutChain.title,
                //adChain: adChain,
                chain: sampleWorkoutChain,
                showHistory: true,
                allowFlag: true,
                key: KeyHelper.sampleWorkoutChainListItemKey,
                index: sampleWorkoutChain.index,
              ),
            if (sampleDietChain != null)
              ChainListItem(
                tutorialChain: sampleDietChain.title,
                //adChain: adChain,
                chain: sampleDietChain,
                showHistory: true,
                allowFlag: true,
                key: KeyHelper.sampleDietChainListItemKey,
                index: sampleDietChain.index,
              ),
            if (sampleMedicineChain != null)
              ChainListItem(
                tutorialChain: sampleMedicineChain.title,
                //adChain: adChain,
                chain: sampleMedicineChain,
                showHistory: true,
                allowFlag: true,
                key: KeyHelper.sampleMedicineChainListItemKey,
                index: sampleMedicineChain.index,
              ),
          ],
        ),
        const Divider(),
        // if (widget.showAd == null || widget.showAd == true)
        //   Container(
        //     margin: const EdgeInsets.all(5),
        //     //padding: const EdgeInsets.only(bottom: 5),
        //     decoration: BoxDecoration(
        //       borderRadius: BorderRadius.circular(20),
        //       color: Theme.of(context).cardColor,
        //     ),
        //     child: const ShowBannerAd(),
        //   ),
      ],
    );
  }
}
