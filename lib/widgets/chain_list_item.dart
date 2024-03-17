import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';

//import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_view.dart';

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
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
        ),
        child: const Icon(Icons.delete),
      ),
      key: ValueKey("chain_list_dismissible_${chain.title}"),
      onDismissed: (direction) async {
        await chainList.removeChain(chain);
      },
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text("Are you sure about deleting this Chain?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    "Yes, Delete it",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "No, it is a mistake",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      // Expanded(
      //   child: ChainActivityListView(chain: chain),
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
