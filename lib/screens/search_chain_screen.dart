import 'package:chain_activities/widgets/list_of_chains.dart';
import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
//import 'package:chain_activities/widgets/app_drawer.dart';

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
  String? textFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    displayChains = chainList.getChainsByFilters(
        textFilter ?? '', showFavorites, showRunning);

    return Semantics(
      label: "Search Chains Screen",
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisSize: MainAxisSize.min,
            children: [
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
                  child: ListOfChains(
                    textFilter: textFilter,
                    showAd: false,
                    showChainControlSummary: false,
                    showChainInReverse: true,
                  ),
                ),
              ),
              AppBar(
                title: TextField(
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  keyboardType: TextInputType.text,
                  cursorColor: Theme.of(context).iconTheme.color,
                  onChanged: (value) {
                    setState(() {
                      textFilter = value;
                    });
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
      ),
    );
  }
}
