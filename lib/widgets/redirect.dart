// ignore_for_file: avoid_print

import 'dart:async';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/screens/how_it_works.dart';
import 'package:chain_activities/screens/load_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Redirect extends StatefulWidget {
  const Redirect({
    Key? key,
  }) : super(key: key);

  @override
  State<Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles;

  @override
  void initState() {
    super.initState();
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

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
          // if (showHelpEntryIndex != -1 &&
          //     systemSettings[showHelpEntryIndex].value == trueSettingValue) {
          if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
            chainList.sharedFile = _sharedFiles![0];
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
