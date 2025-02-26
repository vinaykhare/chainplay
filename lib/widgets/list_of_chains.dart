import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOfChains extends StatefulWidget {
  final String? textFilter;
  final bool showFavorites, showRunning;
  final bool? showChainControlSummary, showAd, showChainInReverse;
  const ListOfChains({
    super.key,
    this.textFilter,
    this.showChainControlSummary,
    this.showAd,
    this.showChainInReverse,
    required this.showFavorites,
    required this.showRunning,
  });

  @override
  State<ListOfChains> createState() => _ListOfChainsState();
}

class _ListOfChainsState extends State<ListOfChains> {
  bool showChainControlSummary = true;
  List<Chain> allChains = [], activeChains = [], favoriteChains = [];
  late ChainList chainList;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: true);
  }

  @override
  Widget build(BuildContext context) {
    // ChainList chainList = Provider.of<ChainList>(context, listen: true);
    // List<Chain> chains = chainList.chains;

    activeChains = chainList.chains
        .where((chain) => chain.chainStatus == statusExecuting)
        .toList();

    bool showFavorites = widget.showFavorites, showRunning = widget.showRunning;
    allChains = chainList.getChainsByFilters(
        widget.textFilter ?? '', showFavorites, showRunning);
    // allChains.sort(
    //   (Chain a, Chain b) {
    //     if (!a.pinned) {
    //       return 1;
    //     } else {
    //       return -1;
    //     }
    //   },
    // );

    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.showChainControlSummary == null ||
            widget.showChainControlSummary == true)
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
        const Divider(),

        Expanded(
          child: ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) =>
                Provider.of<ChainList>(context, listen: false)
                    .rearrangeChains(oldIndex, newIndex),
            itemCount: allChains.length,
            reverse: widget.showChainInReverse != null &&
                widget.showChainInReverse == true,
            itemBuilder: (context, index) {
              Chain chain = allChains[index];
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

        // Container(
        //   width: double.infinity,
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).canvasColor,
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Expanded(
        //         child: TextButton.icon(
        //           icon: Icon(
        //             Icons.favorite,
        //             color: showFavorites
        //                 ? Theme.of(context).secondaryHeaderColor
        //                 : Theme.of(context).disabledColor,
        //           ),
        //           label: Text(
        //             "Favorites",
        //             style: Theme.of(context).textTheme.labelLarge,
        //           ),
        //           onPressed: () async {
        //             setState(() {
        //               showFavorites = !showFavorites;
        //             });
        //           },
        //         ),
        //       ),
        //       Expanded(
        //         child: TextButton.icon(
        //           icon: Icon(
        //             Icons.run_circle,
        //             color: showRunning
        //                 ? Theme.of(context).secondaryHeaderColor
        //                 : Theme.of(context).disabledColor,
        //           ),
        //           label: Text(
        //             "Active",
        //             style: Theme.of(context).textTheme.labelLarge,
        //           ),
        //           onPressed: () {
        //             setState(() {
        //               showRunning = !showRunning;
        //             });
        //           },
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
