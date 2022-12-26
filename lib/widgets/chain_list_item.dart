import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';

//import 'package:chain_events/models/event.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/chain_list.dart';
import 'package:chain_events/widgets/chain_view.dart';

class ChainListItem extends StatelessWidget {
  //final BannerAd? adChain;
  final Chain chain;
  final bool showHistory, allowFlag;
  final int index;

  const ChainListItem({
    super.key,
    //this.adChain,
    required this.chain,
    required this.showHistory,
    required this.allowFlag,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context);
    return Dismissible(
      background: Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: BoxDecoration(
          color: Theme.of(context).errorColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.delete),
            Icon(Icons.delete),
          ],
        ),
      ),
      key: ValueKey("chain_list_dismissible_${chain.title}"),
      onDismissed: (direction) async {
        await chainList.removeChain(chain);
      },
      // Expanded(
      //   child: ChainEventListView(chain: chain),
      // ),
      child: ChainView(
        chain: chain,
        showHistory: showHistory,
        allowFlag: allowFlag,
        key: key,
        index: index,
      ),
    );
  }
}
