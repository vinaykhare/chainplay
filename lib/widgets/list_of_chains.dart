import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/app_header_buttons_help.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  bool showChainControlSummary = false,
      pageInit = false,
      showFavorites = false,
      showRunning = false;
  List<Chain> allChains = [];
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

    if (!pageInit) {
      showFavorites = widget.showFavorites;
      showRunning = widget.showRunning;
      pageInit = true;
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.help),
                onPressed: () {
                  setState(() {
                    showChainControlSummary = !showChainControlSummary;
                  });
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    showFavorites = false;
                    showRunning = false;
                  });
                },
                child: Text(
                  "All Chains",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight:
                            showFavorites == true && showRunning == false
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                ),
              ),
              SizedBox(),
            ],
          ),
        Expanded(
          child: Stack(
            children: [
              ReorderableListView.builder(
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
              AnimatedContainer(
                // height: showChainControlSummary ? 150 : 0,
                width: showChainControlSummary ? 350 : 0,
                // padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                duration: Duration(milliseconds: 500),
                curve: Curves.fastLinearToSlowEaseIn,
                child: (showChainControlSummary &&
                        (widget.showChainControlSummary == null ||
                            widget.showChainControlSummary == true))
                    ? Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.help_outline),
                              ),
                              Text(
                                "Quick Help with Controls",
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    showChainControlSummary =
                                        !showChainControlSummary;
                                  });
                                },
                                icon: Icon(
                                  Icons.cancel,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "1. Buttons on App Header",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          Divider(),
                          const AppHeaderButtonsHelp(),
                          Divider(),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "2. Controls on a Chain Tile",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          Divider(),
                          const ChainTileHelp(),
                          Divider(),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        ),
        const Divider(),
        if (!kIsWeb && (widget.showAd == null || widget.showAd == true))
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
