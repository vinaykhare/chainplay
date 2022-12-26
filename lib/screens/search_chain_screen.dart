import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:chain_events/helpers/constants.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/chain_list.dart';
//import 'package:chain_events/widgets/app_drawer.dart';
import 'package:chain_events/widgets/chain_list_item.dart';

class SearchChainScreen extends StatefulWidget {
  static String routename = "/search_chains";

  const SearchChainScreen({super.key});

  @override
  State<SearchChainScreen> createState() => _SearchChainScreenState();
}

class _SearchChainScreenState extends State<SearchChainScreen> {
  List<Chain> displayChains = [];
  late ChainList chainList;

  bool showFavorites = false, showRunning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: true);
    displayChains = chainList.chains;
    showFavorites = false;
    showRunning = false;
  }

  runPredefinedFilter() {
    if (showFavorites || showRunning) {
      setState(
        () {
          displayChains = chainList.chains
              .where(
                (element) =>
                    (showFavorites && element.pinned == true) ||
                    (showRunning && element.chainStatus == statusExecuting),
              )
              .toList();
        },
      );
    } else {
      setState(() {
        displayChains = chainList.chains;
      });
    }
  }

  runFilter(filter) {
    setState(() {
      showFavorites = false;
      showRunning = false;
    });
    if (filter == '') {
      setState(() {
        displayChains = chainList.chains;
      });
    } else {
      setState(() {
        displayChains = chainList.chains
            .where((element) => element.title
                .toLowerCase()
                .contains(filter.toString().toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: displayChains.length,
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
            Row(
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
                        label: const Text("Favorites"),
                        onPressed: () {
                          showFavorites = !showFavorites;
                          runPredefinedFilter();
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
                        label: const Text("Running"),
                        onPressed: () {
                          showRunning = !showRunning;
                          runPredefinedFilter();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppBar(
              title: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                cursorColor: Theme.of(context).iconTheme.color,
                onChanged: (value) {
                  runFilter(value);
                },
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  label: const Text("Search Chains"),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).primaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
