import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
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
    // List<Chain> chains = chainList.chains;
    bool showFavorites = widget.showFavorites, showRunning = widget.showRunning;
    Chain sampleWorkoutChain = chainList.getChainsByFilters(
        "Sample Workout Chain", showFavorites, showRunning)[0];
    Chain sampleDietChain = chainList.getChainsByFilters(
        "Sample Diet Routine Chain", showFavorites, showRunning)[0];
    Chain sampleMedicineChain = chainList.getChainsByFilters(
        "Sample Medicine Routine Chain", showFavorites, showRunning)[0];
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showChainControlSummary == null ||
            widget.showChainControlSummary == true)
          Column(
            key: KeyHelper.chainControlSummaryKey,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: Theme.of(context).primaryColor,
                ),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      showChainControlSummary = !showChainControlSummary;
                    });
                  },
                  icon: Icon(
                    key: KeyHelper.minmaxChainControlSummaryKey,
                    showChainControlSummary
                        ? Icons.expand_more_rounded
                        : Icons.expand_less_rounded,
                  ),
                  label: Text(
                    "Summary of Chain Controls",
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (showChainControlSummary &&
                  (widget.showChainControlSummary == null ||
                      widget.showChainControlSummary == true))
                const ChainTileHelp(),
            ],
          ),
        Expanded(
          key: KeyHelper.chainListKey,
          child: Column(
            children: [
              ChainListItem(
                tutorialChain: sampleWorkoutChain.title,
                //adChain: adChain,
                chain: sampleWorkoutChain,
                showHistory: true,
                allowFlag: true,
                key: KeyHelper.sampleWorkoutChainListItemKey,
                index: sampleWorkoutChain.index,
              ),
              ChainListItem(
                tutorialChain: sampleDietChain.title,
                //adChain: adChain,
                chain: sampleDietChain,
                showHistory: true,
                allowFlag: true,
                key: KeyHelper.sampleDietChainListItemKey,
                index: sampleDietChain.index,
              ),
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
        ),
        const Divider(),
        if (widget.showAd == null || widget.showAd == true)
          Container(
            margin: const EdgeInsets.all(5),
            //padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
            ),
            child: const ShowBannerAd(),
          ),
      ],
    );
  }
}
