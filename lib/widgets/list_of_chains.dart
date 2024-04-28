import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOfChains extends StatefulWidget {
  final String? textFilter;
  final bool? showChainControlSummary, showAd, showChainInReverse;
  const ListOfChains({
    super.key,
    this.textFilter,
    this.showChainControlSummary,
    this.showAd,
    this.showChainInReverse,
  });

  @override
  State<ListOfChains> createState() => _ListOfChainsState();
}

class _ListOfChainsState extends State<ListOfChains> {
  bool showChainControlSummary = true;
  List<Chain> displayChains = [];
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
    displayChains = chainList.getChainsByFilters(
        widget.textFilter ?? '', showFavorites, showRunning);
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

        // Container(
        //   width: double.infinity,
        //   margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        //   padding: const EdgeInsets.only(bottom: 8),
        //   // decoration: BoxDecoration(
        //   //   color: Theme.of(context).primaryColor,
        //   //   border: Border.all(
        //   //     width: 1,
        //   //     color: Theme.of(context).scaffoldBackgroundColor,
        //   //   ),
        //   // ),
        //   child: const ChainTileHelp(),
        // ),
        if (showChainControlSummary &&
            (widget.showChainControlSummary == null ||
                widget.showChainControlSummary == true))
          const Divider(),
        Expanded(
          child: ReorderableListView.builder(
            key: KeyHelper.chainListKey,
            //reverse: true,
            onReorder: (oldIndex, newIndex) =>
                Provider.of<ChainList>(context, listen: false)
                    .rearrangeChains(oldIndex, newIndex),
            itemCount: displayChains.length,
            reverse: widget.showChainInReverse != null &&
                widget.showChainInReverse == true,
            itemBuilder: (context, index) {
              Chain chain = displayChains[index];
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
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
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
