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
  final bool? showChainControlSummary, showAd, showChainInReverse;
  const ListOfChainsTutorial({
    super.key,
    this.textFilter,
    this.showChainControlSummary,
    this.showAd,
    this.showChainInReverse,
  });

  @override
  State<ListOfChainsTutorial> createState() => _ListOfChainsTutorialState();
}

class _ListOfChainsTutorialState extends State<ListOfChainsTutorial> {
  bool showChainControlSummary = true;
  late ChainList chainList;
  bool showFavorites = false, showRunning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    // ChainList chainList = Provider.of<ChainList>(context, listen: true);
    // List<Chain> chains = chainList.chains;
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
                  color: Theme.of(context).scaffoldBackgroundColor,
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
                    color: Colors.black,
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
        Container(
          key: KeyHelper.chainFiltersKey,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                key: KeyHelper.favoriteChainFilterKey,
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).cardColor,
                          Theme.of(context).primaryColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.favorite,
                        color: showFavorites
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).disabledColor,
                      ),
                      label: Text(
                        "Favorites",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      onPressed: () async {
                        setState(() {
                          showFavorites = !showFavorites;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                key: KeyHelper.activeChainFilterKey,
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).cardColor,
                          Theme.of(context).primaryColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.run_circle,
                        color: showRunning
                            ? Theme.of(context).secondaryHeaderColor
                            : Theme.of(context).disabledColor,
                      ),
                      label: Text(
                        "Active",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      onPressed: () {
                        setState(() {
                          showRunning = !showRunning;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
