import 'package:chain_activities/widgets/help_header.dart';
import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
//import 'package:chain_activities/widgets/app_drawer.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';

class ChainListScreen extends StatelessWidget {
  static String routename = "/chains";

  const ChainListScreen({super.key});

  // late ChainList chainList;
  // List<Chain> chains = [];

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   chainList = Provider.of<ChainList>(context, listen: true);
  //   // chainList.fetchChains().then((value) {
  //   //   setState(() {
  //   //     chains = value;
  //   //   });
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    List<Chain> chains = chainList.chains;

    return Scaffold(
      //key: KeyHelper.navigatorKey,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const ListTile(
          title: Text(
            "C A T",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            "CHAIN ACTIVITIES WITH TIMERS",
            textAlign: TextAlign.center,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //mainAxisSize: MainAxisSize.min,
          children: [
            const HelpHeader(),
            if (chains.isNotEmpty)
              Expanded(
                child: ReorderableListView.builder(
                  reverse: true,
                  onReorder: (oldIndex, newIndex) =>
                      Provider.of<ChainList>(context, listen: false)
                          .rearrangeChains(oldIndex, newIndex),
                  itemCount: chains.length,
                  itemBuilder: (context, index) {
                    Chain chain = chains[index];
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
              )
            else
              Center(
                child: TextButton(
                    onPressed: () async {
                      await chainList.loadSampleChains();
                    },
                    child: CircleAvatar(
                      radius: 150,
                      child: Text(
                        "No Chains Configured!!\n\nPress here\n to add a sample chain to Start.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    )),
              ),
            AppBar(
              centerTitle: true,
              //automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.none,
                      cursorColor: Theme.of(context).cardColor,
                      showCursor: false,
                      onTap: () => Navigator.of(context)
                          .pushNamed(SearchChainScreen.routename),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        label: const Text("Search Chains"),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.of(context).pushNamed(AddChainScreen.routename);
                  //   },
                  //   icon: const Icon(
                  //     Icons.watch_later,
                  //     size: 30,
                  //   ),
                  // )
                ],
              ),
            ),
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
    );
  }
}
