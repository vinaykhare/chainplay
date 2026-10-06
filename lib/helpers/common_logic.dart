import 'package:chain_activities/helpers/common_ui.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CommonLogic {
  Future<bool> setOrientation(bool isLandscape) async {
    if (isLandscape) {
      await SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
    } else {
      await SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
    }
    return isLandscape;
  }

  Future<void> scheduleTheChain(BuildContext context, Chain chain) async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    NavigatorState nav = Navigator.of(context);
    ScaffoldMessengerState scms = ScaffoldMessenger.of(context);
    DateTime? chainStartTime;

    // NavigatorState nav = Navigator.of(context);

    chainList = Provider.of<ChainList>(context, listen: false);

    chainStartTime = await CommonUI().getDateTimeDialog(
      context,
      chainStartTime,
    );

    if (chainStartTime == null) {
      return;
    }

    if (chainStartTime.isBefore(DateTime.now())) {
      chain.at = null;
      return;
    }

    chain.at = chainStartTime;
    Chain chainExecution = await chainList.startChainExecution(chain);
    int chainIndex =
        chainList.chains.indexWhere((sch) => sch.title == chainExecution.title);
    if (chainExecution.at != null &&
        chainList.chains[chainIndex].notificationId == noValueInDB) {
      chainExecution.at = null;
      chainList.chains[chainIndex].at = null;
      await chainList.updateChain(
        chainList.chains[chainIndex],
      );
      await chainList.updateChainExecution(
        chainExecution,
      );

      scms.showSnackBar(
        SnackBar(
          content: Text(
            "Unable to Schedule the Chain: ${chainExecution.title}.\n",
          ),
          action: SnackBarAction(
            //textColor: Colors.white,
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } else {
      int runningChainActivityIndex =
          chainList.getRunningChainActivityIndex(chainExecution);
      await nav.pushReplacementNamed(
        PlayChain.routename,
        arguments: {
          payLoadChainExecId: chainExecution.chainExecutionId,
          payLoadChainName: chainExecution.title,
          payLoadChainActivityIndex:
              runningChainActivityIndex != -1 ? runningChainActivityIndex : 0,
          payLoadChainActivityCount: chain.chainHistory.length,
          payLoadChainAction: playChainActionPause,
        },
      );
    }
  }

  Future<void> playTheChain(BuildContext context, Chain chain) async {
    NavigatorState nav = Navigator.of(context);
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    chainList = Provider.of<ChainList>(context, listen: false);
    Chain chainExecution = await chainList.startChainExecution(chain);

    if (chainExecution.notificationId == trueInDB) {
      await chainList.stopChainExecution(chain);
    } else {
      //await Provider.of<ChainList>(context, listen: false).loadActivities(chain);
      int runningChainActivityIndex =
          chainList.getRunningChainActivityIndex(chainExecution);
      // ChainActivity? chainActivityExecution = runningChainActivityIndex != -1
      //     ? chainExecution.activities[runningChainActivityIndex]
      //     : null;

      await nav.pushNamed(
        PlayChain.routename,
        arguments: {
          payLoadChainExecId: chainExecution.chainExecutionId,
          payLoadChainName: chainExecution.title,
          payLoadChainActivityIndex:
              runningChainActivityIndex != -1 ? runningChainActivityIndex : 0,
          payLoadChainActivityCount: chain.chainHistory.length,
          payLoadChainAction: playChainActionPlay,
        },
      );
    }
  }
}
