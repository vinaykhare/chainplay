import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_list_item.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOfChains extends StatefulWidget {
  const ListOfChains({super.key});

  @override
  State<ListOfChains> createState() => _ListOfChainsState();
}

class _ListOfChainsState extends State<ListOfChains> {
  bool showChainControlSummary = true;
  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    List<Chain> chains = chainList.chains;
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            //reverse: true,
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
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Summary of Chain Controls",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    showChainControlSummary = !showChainControlSummary;
                  });
                },
                child: showChainControlSummary
                    ? const Icon(
                        Icons.expand_less,
                      )
                    : const Icon(
                        Icons.expand_more_outlined,
                      ),
              )
            ],
          ),
        ),
        if (showChainControlSummary)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            padding: const EdgeInsets.only(bottom: 8),
            // decoration: BoxDecoration(
            //   color: Theme.of(context).primaryColor,
            //   border: Border.all(
            //     width: 1,
            //     color: Theme.of(context).scaffoldBackgroundColor,
            //   ),
            // ),
            child: const ChainTileHelp(),
          ),
      ],
    );
  }
}
