// ignore_for_file: avoid_print

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/screens/how_it_works.dart';
import 'package:chain_activities/screens/load_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Redirect extends StatelessWidget {
  const Redirect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context, listen: true);
    return FutureBuilder(
      future:
          Provider.of<ChainList>(context, listen: false).checkAndUpdateConfig(),
      builder: (context, snapshot) {
        // List<SystemSetting> systemSettings = chainList.systemSettings;
        // int showHelpEntryIndex = systemSettings.indexWhere(
        //   (set) => set.key == showHelpOnNextBootKey,
        // );

        if (!chainList.configUpdated) {
          return const LoadScreen();
        } else {
          if (chainList.sharedFile != null) {
            return const ViewChain();
          } else if (chainList.getSettingByKey(showHelpOnNextBootKey).value ==
              trueSettingValue) {
            return const HowItWorks();
          } else {
            return const ChainListScreen();
          }
        }
      },
    );
  }
}
