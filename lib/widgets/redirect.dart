import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/screens/load_screen.dart';
import 'package:chain_activities/screens/show_chain_from_notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Redirect extends StatelessWidget {
  const Redirect({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    return FutureBuilder(
      future:
          Provider.of<ChainList>(context, listen: false).checkAndUpdateConfig(),
      builder: (context, snapshot) {
        if (!chainList.configUpdated) {
          return const LoadScreen();
        } else {
          if (chainList.notificationCameAs != null) {
            return const ShowChainFromNotification();
          } else {
            return const ChainListScreen();
          }
        }
      },
    );
  }
}
