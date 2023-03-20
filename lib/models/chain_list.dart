// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:chain_activities/helpers/sample_chain_configuration.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/screens/play_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/helpers/constants.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:chain_activities/helpers/ad_state.dart';
import 'package:chain_activities/helpers/db_helper.dart';
import 'package:chain_activities/helpers/notification_helper.dart';

import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/system_setting.dart';
import 'package:uuid/uuid.dart';
//import 'package:chain_activities/screens/play_chain_screen.dart';

/*

Table of Content for Functions defined in this class
Chain:
	addChain
	removeChain
	-> updateSchdule
	rearrangeChains
	pinChain
	fetchChains

Activity:
	-> addActivity .. no need as of now.
	removeActivity
	updateActivity
	rearrangeActivites
	updateActivityIndex
	flipDoneActivity
	loadActivities
	fetchActivities

Util:
	clearDataBase
	disposeAds

*/

class ChainList with ChangeNotifier {
  bool loaded = false, configUpdated = false, configUpdateStarted = false;
  List<Chain> chains = [];
  List<Activity> activities = [];
  List<SystemSetting> systemSettings = [];
  NotificationHelper notificationHelper = NotificationHelper();
  Map<String, dynamic>? notificationCameAs;
  // Chain? notificationCameForChain;
  // String? notificaitonCameForUrl;
  List<int> notificationIdsInDB = [];
  //List<int> adIndexInChains = [];
  //final AdState adState;
  final BuildContext context;

  ChainList(
    this.context,
    //this.notificationHelper,
    //this.adState,
  );

  Future<void> initialize() async {
    if (loaded) {
      return;
    }
    await fetchSettings();
    await fetchActivities();
    await fetchChains();

    loaded = true;
    notifyListeners();
  }

  Future<void> checkAndUpdateConfig() async {
    if (configUpdateStarted) {
      return;
    }
    configUpdateStarted = true;
    await notificationHelper.initialize(systemSettings);
    notificationCameAs = null;

    Map<String, dynamic>? checkForNotificationResponse =
        await notificationHelper.localNotificationService
            .checkForNotification();

    for (int chainId = 0; chainId < chains.length; chainId++) {
      Chain chain = chains[chainId];
      collectNotificationIds(chain);
      if (checkForNotificationResponse != null &&
          chain.title == checkForNotificationResponse[payLoadChainName]) {
        notificationCameAs = checkForNotificationResponse;
      }
      // await evaluateChainExecutions(chain);
    }
    configUpdated = true;
    configUpdateStarted = false;
    notifyListeners();
  }

  void collectNotificationIds(Chain chain) {
    if (chain.notificationId == noValueInDB) {
      return;
    }
    notificationIdsInDB.add(chain.notificationId);
    Chain sch = chain;
    for (int activityId = 0; activityId < sch.activities.length; activityId++) {
      if (sch.activities[activityId].startActivityNotificationId ==
          noValueInDB) {
        continue;
      }
      notificationIdsInDB
          .add(sch.activities[activityId].startActivityNotificationId);
      if (sch.activities[activityId].endActivityNotificationId == noValueInDB) {
        continue;
      }
      notificationIdsInDB
          .add(sch.activities[activityId].endActivityNotificationId);
    }
  }

  Future<Map<String, dynamic>> executeChainFurtherPossible(Chain executingChain,
      [int from = 0]) async {
    List<ChainActivity> chainActivities = executingChain.activities;
    DateTime lastActivityEndedAt = executingChain.at!;

    //for (ChainActivity chainActivity in chainActivities) {
    for (int chainActivityIndex = from;
        chainActivityIndex < chainActivities.length;
        chainActivityIndex++) {
      ChainActivity chainActivity = chainActivities[chainActivityIndex];
      if (chainActivity.endedAt != null) {
        lastActivityEndedAt = chainActivity.endedAt ?? DateTime.now();
        continue;
      }

      chainActivity.at = chainActivity.at ?? lastActivityEndedAt;

      if (chainActivity.activityDurationLeft != null) {
        return {
          "executingChain": executingChain,
          "invokeCounter": chainActivityIndex,
          "waitDuration": chainActivity.activityDurationLeft,
          "chainActivity": chainActivity,
          "playScreenType": chainActivity.activity.type,
          "running": chainActivity.activityDurationLeft == null,
          "screenImage":
              chainActivity.activity.specification?[activitySpecImagePath],
          "showTimer": false,
        };
      }

      if (chainActivity.activityDuration.inSeconds == 0 &&
          chainActivity.activity.type == waitActivityInDB) {
        return {
          "executingChain": executingChain,
          "invokeCounter": chainActivityIndex,
          "waitDuration": chainActivity.activityDuration,
          "chainActivity": chainActivity,
          "playScreenType": chainActivity.activity.type,
          "running": chainActivity.activityDurationLeft == null,
          "screenImage":
              chainActivity.activity.specification?[activitySpecImagePath],
          "showTimer": true,
        };
      }

      DateTime activityEndDateTime =
          chainActivity.at!.add(chainActivity.activityDuration);
      if (activityEndDateTime.isAfter(
        DateTime.now(),
      )) {
        return {
          "executingChain": executingChain,
          "invokeCounter": chainActivityIndex,
          "waitDuration": activityEndDateTime.difference(DateTime.now()),
          "chainActivity": chainActivity,
          "playScreenType": chainActivity.activity.type,
          "running": chainActivity.activityDurationLeft == null,
          "screenImage":
              chainActivity.activity.specification?[activitySpecImagePath],
          "showTimer": false,
        };
      }

      if (chainActivity.activityDuration.inSeconds == 0 &&
          (chainActivity.activity.type == systemWaitActivityInDB ||
              chainActivity.activity.type == systemStartActivityInDB) &&
          chainActivityIndex >= (chainActivities.length - 1)) {
        return {
          "executingChain": executingChain,
          "invokeCounter": chainActivityIndex,
          "waitDuration": chainActivity.activityDuration,
          "chainActivity": chainActivity,
          "playScreenType": systemEndActivityInDB,
          "running": chainActivity.activityDurationLeft == null,
          "screenImage":
              chainActivity.activity.specification?[activitySpecImagePath],
          "showTimer": true,
        };
      }

      lastActivityEndedAt = chainActivity.endedAt = activityEndDateTime;
      await updateChainActivityExecutionByActivityId(
          executingChain, chainActivity);
    }

    executingChain.endedAt = lastActivityEndedAt;
    executingChain.chainStatus = statusDone;
    await updateChainExecution(executingChain);

    return {
      "executingChain": executingChain,
      "invokeCounter": chainActivities.length,
      "waitDuration": null,
      "chainActivity": null,
      "playScreenType": null,
      "running": null,
      "screenImage": null,
      "showTimer": false,
    };
  }

  Future<void> addChain(Chain chain, ChainActivity chainActivity) async {
    chain.lastUpdatedAt = DateTime.now();
    int chainIndex = chains.indexWhere((sch) => sch.title == chain.title);

    if (chainIndex == -1) {
      chain.index = chains.length;
      chains.add(chain);
    } else {
      chain.index = chainIndex;
      chains[chainIndex] = chain;
    }

    int activityIndex = activities
        .indexWhere((act) => act.title == chainActivity.activity.title);

    chainActivity.index = chain.activities.length;

    if (activityIndex == -1) {
      activities.add(chainActivity.activity);
      chainActivity.activity.lastUpdatedAt = DateTime.now();
      await DBHelper.insert(
        "activity",
        {
          "activityId": chainActivity.activity.activityId,
          "title": chainActivity.activity.title,
          "type": chainActivity.activity.type,
          "createdAt": chainActivity.activity.createdAt.millisecondsSinceEpoch,
          "lastUpdatedAt":
              chainActivity.activity.lastUpdatedAt.millisecondsSinceEpoch,
          "edit": chainActivity.activity.edit ? 1 : 0,
          "specifications": chainActivity.activity.specification != null
              ? jsonEncode(chainActivity.activity.specification)
              : jsonEncode({
                  activitySpecImagePath: "",
                }),
        },
      );
    } else {
      chainActivity.activity = activities[activityIndex];
    }

    if (chainIndex == -1) {
      await DBHelper.insert(
        "chain",
        {
          "title": chain.title,
          "chainIndex": chain.index,
          "createdAt": chain.createdAt.millisecondsSinceEpoch,
          "lastUpdatedAt": chain.lastUpdatedAt.millisecondsSinceEpoch,
          "pinned": chain.pinned ? 1 : 0,
          "chainStatus": chain.chainStatus,
          "startedAt":
              chain.at == null ? noValueInDB : chain.at!.millisecondsSinceEpoch,
          "pivotDate": chain.pivotDate == null
              ? noValueInDB
              : chain.pivotDate!.millisecondsSinceEpoch,
          "endedAt": chain.endedAt == null
              ? noValueInDB
              : chain.endedAt!.millisecondsSinceEpoch,
          "notificationId": chain.notificationId.toString(),
          "editChain": 1,
          "repeatType": chain.repeatType,
          "repeatTypeGap": chain.repeatTypeGap,
          "repeatCount": chain.repeatCount,
        },
      );
    }
    await DBHelper.insert(
      "chain_activity",
      {
        "title": chain.title,
        "activityId": chainActivity.activity.activityId,
        "activityIndex": chainActivity.index,
        "activityDone": chainActivity.activityDone ? trueInDB : falseInDB,
        "isInterrupted": chainActivity.isInterrupted ? trueInDB : falseInDB,
        "notificationId": jsonEncode({
          "startActivityNotificationId":
              chainActivity.startActivityNotificationId,
          "endActivityNotificationId": chainActivity.endActivityNotificationId,
        }),
        "activityDuration": chainActivity.activityDuration.inSeconds,
        "repeatType": chainActivity.repeatType,
        "repeatTypeGap": chainActivity.repeatTypeGap,
        "repeatCount": chainActivity.repeatCount,
        "startedAt": chainActivity.at == null
            ? noValueInDB
            : chainActivity.at!.millisecondsSinceEpoch,
        "activityDurationLeft": chainActivity.activityDurationLeft == null
            ? noValueInDB
            : chainActivity.activityDurationLeft!.inSeconds,
        "endedAt": chainActivity.endedAt == null
            ? noValueInDB
            : chainActivity.endedAt!.millisecondsSinceEpoch,
        "editChainActivity": chainActivity.edit ? 1 : 0,
      },
    );
    // }
    notifyListeners();
  }

  Future<void> removeChain(Chain chain) async {
    chains.removeWhere((sch) => sch.title == chain.title);
    await cancelScheduledNotification(chain);
    for (Chain chainExec in chain.chainHistory) {
      await cancelScheduledNotificationExecution(chainExec);
    }
    await DBHelper.removeData(
      "chain_activity",
      "title = ?",
      [chain.title],
    );
    await DBHelper.removeData(
      "chain_execution",
      "title = ?",
      [chain.title],
    );
    await DBHelper.removeData(
      "chain",
      "title = ?",
      [chain.title],
    );

    notifyListeners();
  }

  Future<bool> nameExistInDB(String title) async {
    List<Map<String, dynamic>> result = await DBHelper.getDataBySQL(
        'Select title, editChain from chain where editChain = 0 and title = ?',
        [title]);
    if (result.isNotEmpty && result[0]['title'] != "") {
      return true;
    }
    return false;
  }

  Future<void> renameChain(String oldChainTitle, String newChainTitle) async {
    await DBHelper.update(
      "chain",
      {
        "title": newChainTitle,
        "lastUpdatedAt": DateTime.now().millisecondsSinceEpoch,
      },
      "title = ?",
      [oldChainTitle],
    );

    await DBHelper.update(
      "chain_activity",
      {
        "title": newChainTitle,
      },
      "title = ?",
      [oldChainTitle],
    );

    await DBHelper.update(
      "chain_execution",
      {
        "title": newChainTitle,
      },
      "title = ?",
      [oldChainTitle],
    );

    await DBHelper.update(
      "chain_activity_execution",
      {
        "title": newChainTitle,
      },
      "title = ?",
      [oldChainTitle],
    );

    notifyListeners();
  }

  Future<void> addChainToHistory(Chain chainExecution) async {
    await DBHelper.insert(
      "chain_execution",
      {
        "chainExecutionId": chainExecution.chainExecutionId,
        "title": chainExecution.title,
        "startedAt": chainExecution.at?.millisecondsSinceEpoch ?? noValueInDB,
        "pivotDate":
            chainExecution.pivotDate?.millisecondsSinceEpoch ?? noValueInDB,
        "endedAt":
            chainExecution.endedAt?.millisecondsSinceEpoch ?? noValueInDB,
        "notificationId": chainExecution.notificationId,
        "chainStatus": chainExecution.chainStatus,
        "repeatType": chainExecution.repeatType,
        "repeatTypeGap": chainExecution.repeatTypeGap,
        "repeatCount": chainExecution.repeatCount,
      },
    );

    //int chainActivityIndex = 0;

    for (ChainActivity chainActivity in chainExecution.activities) {
      await DBHelper.insert(
        "chain_activity_execution",
        {
          "chainExecutionId": chainExecution.chainExecutionId,
          "title": chainExecution.title,
          "activityId": chainActivity.activity.activityId,
          "activityIndex": chainActivity.index,
          "activityDone": chainActivity.activityDone ? trueInDB : falseInDB,
          "isInterrupted": chainActivity.isInterrupted ? trueInDB : falseInDB,
          "notificationId": jsonEncode({
            "startActivityNotificationId":
                chainActivity.startActivityNotificationId,
            "endActivityNotificationId":
                chainActivity.endActivityNotificationId,
          }),
          "activityDuration": chainActivity.activityDuration.inSeconds,
          "repeatType": chainActivity.repeatType,
          "repeatTypeGap": chainActivity.repeatTypeGap,
          "repeatCount": chainActivity.repeatCount,
          "startedAt": chainActivity.at == null
              ? noValueInDB
              : chainActivity.at!.millisecondsSinceEpoch,
          "activityDurationLeft": chainActivity.activityDurationLeft == null
              ? noValueInDB
              : chainActivity.activityDurationLeft!.inSeconds,
          "endedAt": chainActivity.endedAt == null
              ? noValueInDB
              : chainActivity.endedAt!.millisecondsSinceEpoch,
        },
      );
      //chainActivityIndex++;
    }
  }

  DateTime? getNextStartDateTime(DateTime lastChainEndedAt, String repeatType,
      int repeatTypeGap, int repeatCount) {
    DateTime newStartDate = lastChainEndedAt;
    do {
      switch (repeatType) {
        case repeatTypeSecond:
          newStartDate = lastChainEndedAt.add(
            Duration(seconds: repeatTypeGap),
          );
          break;
        case repeatTypeMinute:
          newStartDate = lastChainEndedAt.add(
            Duration(minutes: repeatTypeGap),
          );
          break;
        case repeatTypeHourly:
          newStartDate = lastChainEndedAt.add(
            Duration(hours: repeatTypeGap),
          );
          break;
        case repeatTypeDaily:
          newStartDate = lastChainEndedAt.add(
            Duration(days: repeatTypeGap),
          );
          break;
        case repeatTypeWeekly:
          newStartDate = DateTime(
            lastChainEndedAt.year,
            lastChainEndedAt.month,
            lastChainEndedAt.day + (7 * repeatTypeGap),
            lastChainEndedAt.hour,
            lastChainEndedAt.minute,
            lastChainEndedAt.second,
          );
          break;
        case repeatTypeMonthly:
          newStartDate = DateTime(
            lastChainEndedAt.year,
            lastChainEndedAt.month + repeatTypeGap,
            lastChainEndedAt.day,
            lastChainEndedAt.hour,
            lastChainEndedAt.minute,
            lastChainEndedAt.second,
          );
          break;
        case repeatTypeYearly:
          newStartDate = DateTime(
            lastChainEndedAt.year + repeatTypeGap,
            lastChainEndedAt.month,
            lastChainEndedAt.day,
            lastChainEndedAt.hour,
            lastChainEndedAt.minute,
            lastChainEndedAt.second,
          );
          break;
        case repeatTypeDoesNotRepeat:
        default:
          return null;
      }
    } while (!newStartDate.isAfter(DateTime.now()));
    return newStartDate;
  }

  Future<Chain> moveChainToHistory(Chain chain) async {
    Chain chainExecution = Chain();
    chainExecution.chainExecutionId = const Uuid().v1();
    chainExecution.title = chain.title;
    chainExecution.at = chain.at ?? DateTime.now();
    chainExecution.pivotDate = chain.at ?? DateTime.now();
    chainExecution.endedAt = null;
    chainExecution.chainStatus = statusDone;
    chainExecution.notificationId = chain.notificationId;
    chainExecution.chainStatus = statusExecuting;
    chainExecution.index = chain.index;
    chainExecution.repeatType = chain.repeatType;
    chainExecution.repeatTypeGap = chain.repeatTypeGap;
    chainExecution.repeatCount = chain.repeatCount;

    for (ChainActivity chainActivity in chain.activities) {
      ChainActivity chainActivityCopy = ChainActivity(
        activity: chainActivity.activity,
        activityDone: chainActivity.activityDone,
        activityDuration: chainActivity.activityDuration,
      );
      if (chainActivityCopy.activity.type == systemStartActivityInDB) {
        chainActivityCopy.repeatType = chainExecution.repeatType;
        chainActivityCopy.repeatTypeGap = chainExecution.repeatTypeGap;
        chainActivityCopy.repeatCount = chainExecution.repeatCount;
        //chainActivityCopy.at = chainExecution.at;
      }
      chainActivityCopy.at = null;
      chainActivityCopy.activityDurationLeft = null;
      chainActivityCopy.endedAt = null;
      chainActivityCopy.isInterrupted = false;
      chainActivityCopy.edit = false;
      chainActivityCopy.startActivityNotificationId =
          chainActivity.startActivityNotificationId;
      chainActivityCopy.endActivityNotificationId =
          chainActivity.endActivityNotificationId;
      chainActivityCopy.index = chainActivity.index;
      chainExecution.activities.add(chainActivityCopy);
    }

    //Start: Workaround to avoid addition of unwanted chains under execution.
    if (chainExecution.activities.isEmpty) {
      return chainExecution;
    }
    //End: Workaround to avoid addition of unwanted chains under execution.

    await addChainToHistory(chainExecution);
    int chainIndex = chains.indexWhere((sch) => sch.title == chain.title);

    chains[chainIndex].chainHistory.insert(0, chainExecution);
    // chains[chainIndex].endedAt = null;
    // if (chains[chainIndex].repeatType != repeatTypeDoesNotRepeat) {
    //   chains[chainIndex].at = getNextStartDateTime(
    //     chains[chainIndex].at!,
    //     chains[chainIndex].repeatType,
    //     chains[chainIndex].repeatTypeGap,
    //     chains[chainIndex].repeatCount,
    //   );
    // }
    // if (chains[chainIndex].repeatCount > 0) {
    //   chains[chainIndex].repeatCount--;
    // }
    // if (chains[chainIndex].repeatCount <= 0) {
    //   chains[chainIndex].repeatType = repeatTypeDoesNotRepeat;
    //   chains[chainIndex].at = null;
    // }

    chains[chainIndex].notificationId = noValueInDB;
    chains[chainIndex].chainStatus = statusExecuting;
    await updateChain(chains[chainIndex]);
    notifyListeners();
    return chainExecution;
  }

  Future<Chain> startChainExecution(Chain chain) async {
    int executingChainIndex = chain.chainHistory
        .indexWhere((sch) => sch.chainStatus == statusExecuting);
    if (executingChainIndex == -1) {
      return await moveChainToHistory(chain);
    }
    return chain.chainHistory[executingChainIndex];
  }

  Future<void> completeTheChain(Chain chain) async {
    int chainIndex = chains.indexWhere((sch) => sch.title == chain.title);
    //chains[chainIndex].endedAt = null;
    if (chains[chainIndex].repeatType != repeatTypeDoesNotRepeat) {
      chains[chainIndex].at = getNextStartDateTime(
        chain.endedAt!,
        chains[chainIndex].repeatType,
        chains[chainIndex].repeatTypeGap,
        chains[chainIndex].repeatCount,
      );
    }
    if (chains[chainIndex].repeatCount > 0) {
      chains[chainIndex].repeatCount--;
      //chains[chainIndex].chainStatus = statusExecuting;
    }
    if (chains[chainIndex].repeatCount == 0) {
      chains[chainIndex].repeatType = repeatTypeDoesNotRepeat;
      chains[chainIndex].at = null;
      chains[chainIndex].endedAt = null;
      chains[chainIndex].chainStatus = statusNotStarted;
    }

    if (chains[chainIndex].repeatCount <= -1) {
      // repeat forever
      chains[chainIndex].chainStatus =
          chains[chainIndex].notificationId == noValueInDB
              ? statusNotStarted
              : statusExecuting;
    }

    if (chains[chainIndex].at != null) {
      Chain chainInExecution = await startChainExecution(chains[chainIndex]);
      await scheduleNotificationForExecution(
          chainInExecution, chainInExecution.at!);

      chains[chainIndex].notificationId = trueInDB;
    } else {
      chains[chainIndex].notificationId = noValueInDB;
    }

    await updateChain(chains[chainIndex]);
    notifyListeners();
  }

  Future<void> stopChainExecution(Chain chain) async {
    int executingChainIndex = chain.chainHistory
        .indexWhere((sch) => sch.chainStatus == statusExecuting);
    if (executingChainIndex != -1) {
      await cancelScheduledNotificationExecution(
          chain.chainHistory[executingChainIndex]);
      await resetChainExecution(chain.chainHistory[executingChainIndex]);
    }
    await resetChain(chain);
  }

  Future<void> updateChain(Chain chain,
      [bool updateLastUpdateDate = true]) async {
    int chainIndex = chains.indexWhere((sch) => sch.title == chain.title);

    if (chainIndex == -1) {
      return;
    }

    chain.lastUpdatedAt =
        updateLastUpdateDate ? DateTime.now() : chain.lastUpdatedAt;
    chains[chainIndex] = chain;

    await DBHelper.update(
      "chain",
      {
        "lastUpdatedAt": chain.lastUpdatedAt.millisecondsSinceEpoch,
        "pinned": chain.pinned,
        "startedAt":
            chain.at != null ? chain.at!.millisecondsSinceEpoch : noValueInDB,
        "pivotDate": chain.pivotDate != null
            ? chain.pivotDate!.millisecondsSinceEpoch
            : noValueInDB,
        "endedAt": chain.endedAt != null
            ? chain.endedAt!.millisecondsSinceEpoch
            : noValueInDB,
        "chainStatus": chain.chainStatus,
        "notificationId": chain.notificationId.toString(),
        "editChain": chain.edit ? 1 : 0,
        "repeatType": chain.repeatType,
        "repeatTypeGap": chain.repeatTypeGap,
        "repeatCount": chain.repeatCount,
      },
      "title = ?",
      [chain.title],
    );

    notifyListeners();
  }

  Future<void> updateChainExecution(Chain chainExecution) async {
    await DBHelper.update(
      "chain_execution",
      {
        "title": chainExecution.title,
        "startedAt": chainExecution.at != null
            ? chainExecution.at!.millisecondsSinceEpoch
            : noValueInDB,
        "pivotDate": chainExecution.pivotDate != null
            ? chainExecution.pivotDate!.millisecondsSinceEpoch
            : noValueInDB,
        "endedAt": chainExecution.endedAt != null
            ? chainExecution.endedAt!.millisecondsSinceEpoch
            : noValueInDB,
        "chainStatus": chainExecution.chainStatus,
        "notificationId": chainExecution.notificationId.toString(),
        "repeatType": chainExecution.repeatType,
        "repeatTypeGap": chainExecution.repeatTypeGap,
        "repeatCount": chainExecution.repeatCount,
      },
      "chainExecutionId = ?",
      [chainExecution.chainExecutionId],
    );

    notifyListeners();
  }

  Future<void> updateChainActivityByActivityId(
      Chain chain, ChainActivity chainActivity) async {
    await DBHelper.update(
      "chain_activity",
      {
        "activityDone": chainActivity.activityDone ? trueInDB : falseInDB,
        "isInterrupted": chainActivity.isInterrupted ? trueInDB : falseInDB,
        "notificationId": jsonEncode({
          "startActivityNotificationId":
              chainActivity.startActivityNotificationId,
          "endActivityNotificationId": chainActivity.endActivityNotificationId,
        }),
        "activityDuration": chainActivity.activityDuration.inSeconds,
        "repeatType": chainActivity.repeatType,
        "repeatTypeGap": chainActivity.repeatTypeGap,
        "repeatCount": chainActivity.repeatCount,
        "startedAt": chainActivity.at != null
            ? chainActivity.at!.millisecondsSinceEpoch
            : noValueInDB,
        "activityDurationLeft": chainActivity.activityDurationLeft != null
            ? chainActivity.activityDurationLeft!.inSeconds
            : noValueInDB,
        "endedAt": chainActivity.endedAt != null
            ? chainActivity.endedAt!.millisecondsSinceEpoch
            : noValueInDB,
        "editChainActivity": chainActivity.edit ? 1 : 0,
      },
      "title = ? and activityId = ? and activityIndex = ?",
      [
        chain.title,
        chainActivity.activity.activityId,
        chainActivity.index,
      ],
    );
    notifyListeners();
  }

  Future<void> updatChainActivityByChainName(
    Chain chain, [
    bool editChainActivity = false,
  ]) async {
    await DBHelper.update(
      "chain_activity",
      {
        // "activityDone": chain.chainStatus,
        // "isInterrupted": chain.chainStatus,
        "editChainActivity": editChainActivity,
      },
      "title = ?",
      [chain.title],
    );
    notifyListeners();
  }

  Future<void> updateChainActivityExecutionByActivityId(
      Chain chain, ChainActivity chainActivity) async {
    await DBHelper.update(
      "chain_activity_execution",
      {
        "activityDone": chainActivity.activityDone ? trueInDB : falseInDB,
        "isInterrupted": chainActivity.isInterrupted ? trueInDB : falseInDB,
        "notificationId": jsonEncode({
          "startActivityNotificationId":
              chainActivity.startActivityNotificationId,
          "endActivityNotificationId": chainActivity.endActivityNotificationId,
        }),
        "activityDuration": chainActivity.activityDuration.inSeconds,
        "repeatType": chainActivity.repeatType,
        "repeatTypeGap": chainActivity.repeatTypeGap,
        "repeatCount": chainActivity.repeatCount,
        "startedAt": chainActivity.at != null
            ? chainActivity.at!.millisecondsSinceEpoch
            : noValueInDB,
        "activityDurationLeft": chainActivity.activityDurationLeft != null
            ? chainActivity.activityDurationLeft!.inSeconds
            : noValueInDB,
        "endedAt": chainActivity.endedAt != null
            ? chainActivity.endedAt!.millisecondsSinceEpoch
            : noValueInDB,
      },
      "chainExecutionId = ? and title = ? and activityId = ? and activityIndex = ?",
      [
        chain.chainExecutionId,
        chain.title,
        chainActivity.activity.activityId,
        chainActivity.index,
      ],
    );
    notifyListeners();
  }

  Future<void> resetChain(Chain chain) async {
    await cancelScheduledNotification(chain);

    for (ChainActivity activity in chain.activities) {
      activity.edit = false;
      activity.activityDone = false;
      activity.isInterrupted = false;
      activity.at = null;
      activity.endedAt = null;
    }

    await DBHelper.update(
      "chain_activity",
      {
        "activityDone": statusNotStarted,
        "isInterrupted": statusNotStarted,
        "startedAt": noValueInDB,
        "activityDurationLeft": noValueInDB,
        "endedAt": noValueInDB,
        "editChainActivity": 0,
      },
      "title = ?",
      [chain.title],
    );

    chain.at = chain.endedAt = chain.pivotDate = null;
    chain.notificationId = noValueInDB;
    chain.chainStatus = statusNotStarted;
    chain.repeatType = repeatTypeDoesNotRepeat;
    chain.repeatTypeGap = repeatTypeDefaultGap;
    chain.repeatCount = repeatTypeDefaultCount;
    chain.lastUpdatedAt = DateTime.now();
    await updateChain(chain);

    notifyListeners();
  }

  Future<void> resetChainExecution(Chain chainExecution) async {
    await cancelScheduledNotificationExecution(chainExecution);

    int indexOfChain =
        chains.indexWhere((sch) => sch.title == chainExecution.title);

    chains[indexOfChain].chainHistory.removeWhere(
        (schEx) => schEx.chainExecutionId == chainExecution.chainExecutionId);

    await DBHelper.removeData("chain_activity_execution",
        "chainExecutionId = ?", [chainExecution.chainExecutionId]);
    await DBHelper.removeData("chain_execution", "chainExecutionId = ?",
        [chainExecution.chainExecutionId]);
    notifyListeners();
  }

  Future<void> removeActivityFromChain(
      Chain chain, ChainActivity chainActivity) async {
    //chains.removeWhere((sc) => sc.name == chain.name);

    //Cancel Notification
    if (chainActivity.startActivityNotificationId != noValueInDB) {
      await notificationHelper
          .cancelNotificationById(chainActivity.startActivityNotificationId);
    }

    if (chainActivity.endActivityNotificationId != noValueInDB) {
      await notificationHelper
          .cancelNotificationById(chainActivity.endActivityNotificationId);
    }

    await DBHelper.removeData(
      "chain_activity",
      "title = ? and activityId = ? and activityIndex = ?",
      [chain.title, chainActivity.activity.activityId, chainActivity.index],
    );
    await DBHelper.removeData(
      "chain_activity",
      "title = ? and activityIndex = ?",
      [
        chain.title,
        chainActivity.index + 1,
      ],
    );

    int indexOfChainActivity = chain.activities.indexWhere((activityArg) =>
        activityArg.activity.activityId == chainActivity.activity.activityId);

    chain.activities.removeAt(indexOfChainActivity);
    chain.activities.removeAt(indexOfChainActivity);

    if (chain.activities.length == 1) {
      ChainActivity startChainActivity = chain.activities[0];
      await DBHelper.removeData(
        "chain_activity",
        "title = ? and activityIndex = ?",
        [
          chain.title,
          startChainActivity.index,
        ],
      );
      chain.activities = [];
    }

    updateActivityIndex(chain);
    chain.lastUpdatedAt = DateTime.now();
    await updateChain(chain);
    notifyListeners();
  }

  Future<void> removeActivity(Activity activity) async {
    DBHelper.removeData(
      "activity",
      "activityId = ?",
      [activity.activityId],
    );
  }

  Future<void> updateActivity(Activity activity) async {
    activity.lastUpdatedAt = DateTime.now();
    await DBHelper.update(
      "activity",
      {
        "title": activity.title,
        "type": activity.type,
        "lastUpdatedAt": activity.lastUpdatedAt.millisecondsSinceEpoch,
        "edit": activity.edit ? 1 : 0,
        "specifications": activity.specification != null
            ? jsonEncode(activity.specification)
            : jsonEncode({
                activitySpecImagePath: "",
              })
      },
      "activityId = ?",
      [activity.activityId],
    );
    notifyListeners();
  }

  /* Just for testing */
  Future<void> clearDataBase() async {
    await DBHelper.removeData('chain_activity_execution', "", []);
    await DBHelper.removeData('chain_execution', "", []);
    await DBHelper.removeData('chain_activity', "", []);
    await DBHelper.removeData('activity', "", []);
    await DBHelper.removeData('chain', "", []);
    setSetting("DARK THEME", "FALSE");
    setSetting("Notification Type", "None,App Notification");
    setSetting("App Sound", "TRUE");
    // setSetting("Show help on next boot", "TRUE");
    // await DBHelper.insert("settings", {
    //   "key": "DARK THEME",
    //   "value": "FALSE",
    //   "type": "BOOL",
    // });
    // await DBHelper.insert("settings", {
    //   "key": "Notification Type",
    //   "value": "App Notification,None",
    //   "type": "LIST",
    // });
    // await DBHelper.insert("settings", {
    //   "key": "App Sound",
    //   "value": "TRUE",
    //   "type": "BOOL",
    // });
    chains = [];

    activities = [];
    loaded = false;
    configUpdated = false;
    configUpdateStarted = false;

    notificationCameAs = {};
    notificationIdsInDB = [];

    // await loadSampleChains();
    notifyListeners();
  }

  Future<void> rearrangeChains(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var itemAtOldIndex = chains.removeAt(oldIndex);
    chains.insert(newIndex, itemAtOldIndex);

    await updateChainIndex();
    notifyListeners();
  }

  Future<void> rearrangeActivites(
      Chain chain, int oldIndex, int newIndex) async {
    // if (oldIndex == newIndex) {
    //   return;
    // }

    if (oldIndex > newIndex) {
      newIndex += 1;
    }

    if (chain.activities[newIndex].activity.title == systemWaitActivityTitle) {
      if (oldIndex > newIndex) {
        newIndex += 1;
      } else {
        newIndex -= 1;
      }
    }

    if (oldIndex < newIndex) {
      ChainActivity tempActivity = chain.activities[oldIndex];
      for (int i = oldIndex; i < newIndex; i += 2) {
        chain.activities[i] = chain.activities[i + 2];
      }
      chain.activities[newIndex] = tempActivity;
    } else {
      ChainActivity tempActivity = chain.activities[oldIndex];
      for (int i = oldIndex; i > newIndex; i -= 2) {
        chain.activities[i] = chain.activities[i - 2];
      }
      chain.activities[newIndex] = tempActivity;
    }

    // if (chain.activities[newIndex].activity.title ==
    //     systemWaitActivityTitle) {
    //   if (oldIndex > newIndex) {
    //     newIndex += 1;
    //   } else {
    //     newIndex -= 1;
    //   }
    // }

    // if (chain.activities[oldIndex].activity.title ==
    //     systemWaitActivityTitle) {
    //   if (oldIndex > newIndex) {
    //     oldIndex -= 1;
    //   } else {
    //     oldIndex += 1;
    //   }
    // }

    // var itemAtOldIndex = chain.activities.removeAt(oldIndex);
    // chain.activities.insert(newIndex, itemAtOldIndex);

    await updateActivityIndex(chain);
    chain.lastUpdatedAt = DateTime.now();
    await updateChain(chain);
    notifyListeners();
  }

  //helper function
  Future<void> updateActivityIndex(Chain chain) async {
    int dbIndex = 0;
    for (ChainActivity chainActivity in chain.activities) {
      // if (chainActivity.activity.title == systemWaitActivityTitle) {
      //   continue;
      // }
      await DBHelper.update(
        "chain_activity",
        {
          "activityIndex": dbIndex,
        },
        "title = ? and activityId = ? and activityIndex = ?",
        [chain.title, chainActivity.activity.activityId, chainActivity.index],
      );
      chainActivity.index = dbIndex;
      dbIndex += 1;
    }
  }

  //helper function
  Future<void> updateChainIndex() async {
    int dbIndex = 0;
    for (Chain chain in chains) {
      // if (chain.adBanner != null) {
      //   continue;
      // }
      await DBHelper.update(
        "chain",
        {
          "chainIndex": dbIndex,
        },
        "title = ?",
        [chain.title],
      );
      dbIndex++;
    }
  }

  //helper function
  bool allActivitiesDone(Chain chain) {
    bool allDone = true;
    for (int i = 0; i < chain.activities.length; i++) {
      if (chain.activities[i].endedAt != null ||
          chain.activities[i].isInterrupted == false) {
        allDone = false;
        break;
      }
    }
    //chain.activities = [];
    return allDone;
  }

  Future<void> flipDoneActivity(
      Chain chain, ChainActivity chainActivity) async {
    chainActivity.activityDone = !chainActivity.activityDone;
    if (chainActivity.endedAt == null) {
      chainActivity.endedAt = DateTime.now();
      chainActivity.activityDurationLeft = null;
    } else {
      chainActivity.endedAt = null;
    }

    await updateChainActivityExecutionByActivityId(
      chain,
      chainActivity,
    );

    notifyListeners();
  }

  Future<void> flipDoneRestAfterActivity(
      Chain chain, ChainActivity chainActivity) async {
    chainActivity.isInterrupted = !chainActivity.isInterrupted;
    if (chainActivity.endedAt == null) {
      chainActivity.endedAt = DateTime.now();
    } else {
      chainActivity.endedAt = null;
    }
    await updateChainActivityExecutionByActivityId(
      chain,
      chainActivity,
    );

    notifyListeners();
  }

  Future<void> playNotificationSound() async {
    await notificationHelper.playNotificationSound();
  }

  Future<bool> speakText(String text) async {
    await notificationHelper.speakText(text);
    return notificationHelper.isTtsPlaying;
  }

  Future<bool> speakTextWithoutWait(String text) async {
    await notificationHelper.speakTextWithoutWait(text);
    return notificationHelper.isTtsPlaying;
  }

  Future<bool> stopSpeech() async {
    await notificationHelper.stopSpeech();
    return notificationHelper.isTtsPlaying;
  }

  bool isTtsPlaying() {
    return notificationHelper.isTtsPlaying;
  }

  Future<bool?> askNotificationPermission() async {
    return await notificationHelper.askNotificationPermission();
  }

  // disposeAds() {
  //   for (int i = 0; i < adIndexInChains.length; i++) {
  //     chains[adIndexInChains[i]].dispose();
  //   }
  // }

  DateTime? getDateValueFromDB(int? dateColumnValue) {
    if (dateColumnValue != null && dateColumnValue != -1) {
      return DateTime.fromMillisecondsSinceEpoch(dateColumnValue);
    } else {
      return null;
    }
  }

  Future<void> setSetting(String key, String value) async {
    int keyIndex = systemSettings.indexWhere((set) => set.key == key);
    systemSettings[keyIndex].value = value;
    await DBHelper.update(
      'settings',
      {
        'value': value,
      },
      'key = ?',
      [key],
    );
    notificationHelper.systemSetting = systemSettings;
    notifyListeners();
  }

  Future<List<SystemSetting>> fetchSettings() async {
    List<Map<String, dynamic>> loadedSettings =
        await DBHelper.getData("settings", "type ASC");
    systemSettings = [];
    for (var loadedSetting in loadedSettings) {
      SystemSetting setting = SystemSetting();
      setting.key = loadedSetting["key"];
      setting.value = loadedSetting["value"];
      setting.type = loadedSetting["type"];
      systemSettings.add(setting);
    }

    return systemSettings;
  }

  Future<void> loadSampleChains() async {
    for (Chain configuredChain in sampleChains) {
      int chainIndex =
          chains.indexWhere((chn) => chn.title == configuredChain.title);
      if (chainIndex != -1) {
        await removeChain(chains[chainIndex]);
      }
      Chain chain = Chain();
      chain.title = configuredChain.title;
      for (ChainActivity configuredChainActivity
          in configuredChain.activities) {
        chain.activities.add(configuredChainActivity);
        await addChain(chain, configuredChainActivity);
      }
      //chains.add(chain);
    }
  }

  Future<List<ChainActivity>> loadActivities(Chain chain) async {
    List<Map<String, dynamic>> loadedChainActivity =
        await DBHelper.getDataBySQL(
      '''
      SELECT chain_activity.*, activity.*
      FROM chain_activity
      JOIN activity ON (chain_activity.activityId = activity.activityId)
      WHERE chain_activity.title = ?
      ORDER BY chain_activity.activityIndex
      ''',
      [chain.title],
    );
    chain.activities = [];
    for (var chainActivity in loadedChainActivity) {
      ChainActivity tempActivity = ChainActivity(
        activity: Activity(
          activityId: chainActivity['activityId'],
          title: chainActivity['title'],
          createdAt:
              DateTime.fromMillisecondsSinceEpoch(chainActivity["createdAt"]),
          lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(
              chainActivity["lastUpdatedAt"]),
          type: chainActivity['type'],
          specification: chainActivity["specifications"] != null
              ? jsonDecode(chainActivity["specifications"])
                  as Map<String, dynamic>
              : {},
        ),
        activityDone: chainActivity['activityDone'] == 1,
        activityDuration: Duration(seconds: chainActivity['activityDuration']),
        repeatType: chainActivity['repeatType'] ?? repeatTypeDoesNotRepeat,
        repeatTypeGap: chainActivity['repeatTypeGap'] ?? repeatTypeDefaultGap,
        repeatCount: chainActivity['repeatCount'] ?? repeatTypeDefaultCount,
      );
      tempActivity.isInterrupted = chainActivity['isInterrupted'] == 1;
      tempActivity.at = getDateValueFromDB(chainActivity["startedAt"]);
      tempActivity.activityDurationLeft =
          chainActivity['activityDurationLeft'] == null ||
                  chainActivity['activityDurationLeft'] == noValueInDB
              ? null
              : Duration(seconds: chainActivity['activityDurationLeft']);
      tempActivity.endedAt = getDateValueFromDB(chainActivity["endedAt"]);
      tempActivity.activity.edit = chainActivity['edit'] == 1;
      tempActivity.edit = chainActivity['editChainActivity'] == 1;
      Map<String, dynamic>? notifications =
          jsonDecode(chainActivity['notificationId']);
      if (notifications != null) {
        tempActivity.startActivityNotificationId =
            notifications["startActivityNotificationId"];
        tempActivity.endActivityNotificationId =
            notifications["endActivityNotificationId"];
      }

      tempActivity.index = chainActivity['activityIndex'];
      chain.activities.add(tempActivity);
    }
    return chain.activities;
  }

  Future<Activity?> getActivityByActivityId(String activityId) async {
    List<Map<String, dynamic>> activityFromDB = await DBHelper.getData(
        'activity', 'activityId', 'activityId = ?', [activityId]);
    if (activityFromDB.isEmpty) {
      return null;
    }
    return Activity(
      activityId: activityFromDB[0]['activityId'],
      title: activityFromDB[0]['title'],
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(activityFromDB[0]["createdAt"]),
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(
          activityFromDB[0]["lastUpdatedAt"]),
      type: activityFromDB[0]['type'],
      specification: activityFromDB[0]["specifications"] != null
          ? jsonDecode(activityFromDB[0]["specifications"])
              as Map<String, dynamic>
          : {},
    );
  }

  Chain? getRunningChain(Chain parentChain) {
    for (int i = 0; i < parentChain.chainHistory.length; i++) {
      if (parentChain.chainHistory[i].chainStatus == statusDone) {
        continue;
      }
      return parentChain.chainHistory[i];
    }
    return null;
  }

  List<Chain> getChainsByPredefinedFilter(
      bool showFavorites, bool showRunning) {
    List<Chain> result = showFavorites || showRunning
        ? chains
            .where(
              (element) =>
                  (showFavorites && element.pinned == true) ||
                  (showRunning && element.chainStatus == statusExecuting),
            )
            .toList()
        : chains;

    notifyListeners();
    return result;
  }

  List<Chain> getChainsByTextFilter(String filter) {
    List<Chain> result = filter.isEmpty || filter == ''
        ? chains
        : chains
            .where((element) =>
                element.title
                    .toLowerCase()
                    .contains(filter.toString().toLowerCase()) ||
                element.activities.indexWhere((act) => act.activity.title
                        .toLowerCase()
                        .contains(filter.toString().toLowerCase())) !=
                    -1)
            .toList();

    notifyListeners();
    return result;
  }

  Future<List<ChainActivity>> loadChainActivityHistory(
      Chain chainExecution) async {
    List<Map<String, dynamic>> loadedChainActivityHistory =
        await DBHelper.getData(
      "chain_activity_execution",
      "activityIndex",
      "chainExecutionId = ?",
      [
        chainExecution.chainExecutionId,
      ],
    );

    List<ChainActivity> result = [];
    for (var chainActivity in loadedChainActivityHistory) {
      Activity? activityRetrieved =
          await getActivityByActivityId(chainActivity['activityId']);
      if (activityRetrieved == null) {
        continue;
      }
      ChainActivity tempActivity = ChainActivity(
        activity: activityRetrieved,
        activityDone: chainActivity['activityDone'] == statusDone,
        activityDuration: Duration(seconds: chainActivity['activityDuration']),
        repeatType: chainActivity['repeatType'] ?? repeatTypeDoesNotRepeat,
        repeatTypeGap: chainActivity['repeatTypeGap'] ?? repeatTypeDefaultGap,
        repeatCount: chainActivity['repeatCount'] ?? repeatTypeDefaultCount,
      );
      tempActivity.isInterrupted = chainActivity['isInterrupted'] == statusDone;
      tempActivity.at = getDateValueFromDB(chainActivity["startedAt"]);
      tempActivity.activityDurationLeft =
          chainActivity['activityDurationLeft'] == null ||
                  chainActivity['activityDurationLeft'] == noValueInDB
              ? null
              : Duration(seconds: chainActivity['activityDurationLeft']);
      tempActivity.endedAt = getDateValueFromDB(chainActivity["endedAt"]);

      Map<String, dynamic>? notifications =
          jsonDecode(chainActivity['notificationId']);
      if (notifications != null) {
        tempActivity.startActivityNotificationId =
            notifications["startActivityNotificationId"];
        tempActivity.endActivityNotificationId =
            notifications["endActivityNotificationId"];
      }
      tempActivity.index = chainActivity['activityIndex'];
      result.add(tempActivity);
    }
    return result;
  }

  Future<List<Chain>> loadChainHistory(Chain chain) async {
    List<Map<String, dynamic>> loadedChainHistory = await DBHelper.getData(
        "chain_execution", "startedAt DESC", "title = ?", [chain.title]);
    List<Chain> result = [];
    for (var chainHistory in loadedChainHistory) {
      Chain chainExecution = Chain();

      chainExecution.chainExecutionId = chainHistory['chainExecutionId'];
      chainExecution.title = chainHistory['title'];
      chainExecution.at = getDateValueFromDB(chainHistory["startedAt"]);
      chainExecution.pivotDate = getDateValueFromDB(chainHistory["pivotDate"]);
      chainExecution.endedAt = getDateValueFromDB(chainHistory["endedAt"]);
      chainExecution.chainStatus = chainHistory['chainStatus'];
      chainExecution.notificationId = int.parse(chainHistory["notificationId"]);
      chainExecution.activities =
          await loadChainActivityHistory(chainExecution);
      chainExecution.repeatType =
          chainHistory['repeatType'] ?? repeatTypeDoesNotRepeat;
      chainExecution.repeatTypeGap =
          chainHistory['repeatTypeGap'] ?? repeatTypeDefaultGap;
      chainExecution.repeatCount =
          chainHistory['repeatCount'] ?? repeatTypeDefaultCount;
      result.add(chainExecution);
    }
    return result;
  }

  Future<List<Chain>> fetchChains() async {
    List<Map<String, dynamic>> loadedChain =
        await DBHelper.getData("chain", "chainIndex DESC");
    chains = [];
    for (var chain in loadedChain) {
      Chain tempChain = Chain();
      tempChain.title = chain["title"];
      tempChain.at = getDateValueFromDB(chain["startedAt"]);
      tempChain.pivotDate = getDateValueFromDB(chain["pivotDate"]);
      tempChain.endedAt = getDateValueFromDB(chain["endedAt"]);
      tempChain.createdAt = getDateValueFromDB(chain["createdAt"])!;
      tempChain.lastUpdatedAt = getDateValueFromDB(chain["lastUpdatedAt"])!;
      tempChain.pinned = chain["pinned"] == 1;
      tempChain.chainStatus = chain["chainStatus"];
      tempChain.activities = await loadActivities(tempChain);
      tempChain.chainHistory = await loadChainHistory(tempChain);
      tempChain.edit = chain["editChain"] == 1;
      tempChain.notificationId = int.parse(chain["notificationId"]);
      tempChain.index = chain["chainIndex"];
      tempChain.repeatType = chain["repeatType"] ?? repeatTypeDoesNotRepeat;
      tempChain.repeatTypeGap = chain['repeatTypeGap'] ?? repeatTypeDefaultGap;
      tempChain.repeatCount = chain['repeatCount'] ?? repeatTypeDefaultCount;
      chains.add(tempChain);
    }

    //Add ads to Chain
    // adIndexInChains = [];
    // for (var i = 1; i < chains.length + 1; i += 5) {
    //   adIndexInChains.add(i);
    //   Chain adChain = Chain();
    //   adChain.name = "Sponsored..$i";
    //   adChain.adBanner = BannerAd(
    //     adUnitId: adState.bannerAdUnitId,
    //     size: AdSize.banner,
    //     request: const AdRequest(),
    //     listener: adState.adListener,
    //   )..load();
    //   chains.insert(i, adChain);
    // }
    return chains;
  }

  Future<List<Activity>> fetchActivities() async {
    List<Map<String, dynamic>> loadedActivities =
        await DBHelper.getData("activity", "activityId");

    activities = [];

    for (var activity in loadedActivities) {
      Activity tempActivity = Activity(
        activityId: activity["activityId"],
        title: activity["title"],
        createdAt: DateTime.fromMillisecondsSinceEpoch(activity["createdAt"]),
        lastUpdatedAt:
            DateTime.fromMillisecondsSinceEpoch(activity["lastUpdatedAt"]),
        type: activity["type"],
        specification: activity["specifications"] != null
            ? jsonDecode(activity["specifications"]) as Map<String, dynamic>
            : {},
      );
      // tempActivity.activityDuration =
      //     Duration(seconds: activity["activityDuration"] ?? 0);
      // tempActivity.repeatType =
      //     Duration(seconds: activity["repeatType"] ?? 0);
      // tempActivity.at = getDateValueFromDB(activity["startedAt"]);
      // tempActivity.endedAt = getDateValueFromDB(activity["endedAt"]);
      tempActivity.edit = activity["edit"] == 1;
      activities.insert(0, tempActivity);
    }

    return activities;
  }

  int getNextNotificationId() {
    int nextNotificationId = 0;
    while (notificationIdsInDB.contains(nextNotificationId)) {
      nextNotificationId++;
    }
    notificationIdsInDB.add(nextNotificationId);
    return nextNotificationId;
  }

  Future<DateTime?> scheduleNotificationForExecution(
    Chain chain,
    DateTime fromDateTime,
  ) async {
    int countOfActivities = chain.activities.length;
    chain.notificationId = trueInDB;
    await updateChainExecution(chain);
    bool noBreakChain = true;
    for (int i = 0; i < countOfActivities; i++) {
      if (chain.activities[i].endedAt != null) {
        fromDateTime = chain.activities[i].endedAt!;
        continue;
      }
      if (chain.activities[i].activity.type == systemWaitActivityInDB) {
        fromDateTime = fromDateTime.add(chain.activities[i].activityDuration);
        fromDateTime = fromDateTime.add(const Duration(microseconds: 1));
        continue;
      }
      int nextNotificationId = getNextNotificationId();
      String activityTitle = chain.activities[i].activity.title;

      if (chain.activities[i].activity.type == systemStartActivityInDB) {
        //chain.notificationId = nextNotificationId;
        activityTitle = "Chain of Activities '${chain.title}'";
        //await updateChainExecution(chain);
      }
      if (chain.activities[i].startActivityNotificationId == noValueInDB) {
        notificationHelper.cancelNotificationById(
            chain.activities[i].startActivityNotificationId);
      }
      chain.activities[i].startActivityNotificationId =
          await notificationHelper.scheduleNotification(
        fromDateTime,
        nextNotificationId,
        chain.activities.length > 1 ? chain.title : "Scheduled Alarm",
        chain.activities.length > 1
            ? "$activityTitle has Started."
            : "Complete your Scheduled Alarm",
        {
          payLoadChainName: chain.title,
          payLoadChainExecId: chain.chainExecutionId,
          payLoadWidgetUrl: PlayChain.routename,
          payLoadChainActivityIndex: i + 1,
          payLoadChainActivityCount: chain.activities.length,
        },
      );

      await updateChainActivityExecutionByActivityId(
        chain,
        chain.activities[i],
      );

      if (chain.activities[i].activity.type != systemWaitActivityInDB &&
          chain.activities[i].activity.type != systemStartActivityInDB &&
          (chain.activities[i].activityDuration.inSeconds == 0 ||
              (chain.activities[i].activityDurationLeft != null &&
                  chain.activities[i].activityDurationLeft!.inSeconds > 0))) {
        noBreakChain = false;
        break;
      }
      DateTime dateTimeAfterDurationAddition =
          fromDateTime.add(chain.activities[i].activityDuration);
      if (fromDateTime == dateTimeAfterDurationAddition) {
        fromDateTime = fromDateTime.add(const Duration(microseconds: 1));
        continue;
      }
      fromDateTime = dateTimeAfterDurationAddition;

      // Schedule Activity end notification
      nextNotificationId = getNextNotificationId();
      if (i == (countOfActivities - 2)) {
        activityTitle = "Chain of Activities '${chain.title}'";
      }
      if (chain.activities[i].endActivityNotificationId != noValueInDB) {
        notificationHelper.cancelNotificationById(
            chain.activities[i].endActivityNotificationId);
      }
      chain.activities[i].endActivityNotificationId =
          await notificationHelper.scheduleNotification(
        fromDateTime,
        nextNotificationId,
        chain.activities.length > 1 ? chain.title : "Scheduled Alarm",
        chain.activities.length > 1
            ? "$activityTitle has Ended."
            : "Complete your Scheduled Alarm",
        {
          payLoadChainName: chain.title,
          payLoadChainExecId: chain.chainExecutionId,
          payLoadWidgetUrl: PlayChain.routename,
          payLoadChainActivityIndex: i + 2,
          payLoadChainActivityCount: chain.activities.length,
        },
      );

      await updateChainActivityExecutionByActivityId(
        chain,
        chain.activities[i],
      );
      fromDateTime = fromDateTime.add(const Duration(microseconds: 1));
    }
    notifyListeners();
    return noBreakChain ? fromDateTime : null;
  }

  Future<void> cancelScheduledNotificationExecution(Chain chain) async {
    //Cancel Notifications
    //await cancelScheduledNotification(chain);
    for (ChainActivity chainActivity in chain.activities) {
      if (chainActivity.startActivityNotificationId != noValueInDB) {
        await notificationHelper
            .cancelNotificationById(chainActivity.startActivityNotificationId);
        chainActivity.startActivityNotificationId = noValueInDB;
      }
      if (chainActivity.endActivityNotificationId != noValueInDB) {
        await notificationHelper
            .cancelNotificationById(chainActivity.endActivityNotificationId);
        chainActivity.endActivityNotificationId = noValueInDB;
      }
      await updateChainActivityExecutionByActivityId(chain, chainActivity);
    }

    // await DBHelper.update(
    //   "chain_activity",
    //   {
    //     "notificationId": noValueInDB.toString(),
    //   },
    //   "title = ?",
    //   [chain.title],
    // );
    notifyListeners();
  }

  Future<void> cancelScheduledNotification(Chain chain) async {
    //Cancel Notifications
    if (chain.notificationId != noValueInDB) {
      //await notificationHelper.cancelNotificationById(chain.notificationId);
      chain.notificationId = noValueInDB;
      await updateChainExecution(chain);
    }
    notifyListeners();
  }

  void printAllNotifications() {
    for (int i = 0; i < chains.length; i++) {
      for (int j = 0; j < chains[i].chainHistory.length; j++) {
        if (chains[i].chainHistory[j].endedAt != null) {
          continue;
        }
        print(
          "Notification for Chain ${chains[i].title} is ${chains[i].notificationId}",
        );
        for (int k = 0; k < chains[i].chainHistory[j].activities.length; k++) {
          print(
            "Start Notification for Activity ${chains[i].chainHistory[j].activities[k].activity.title} is ${chains[i].chainHistory[j].activities[k].startActivityNotificationId},",
          );
          print(
            "End Notification for Activity ${chains[i].chainHistory[j].activities[k].activity.title} is ${chains[i].chainHistory[j].activities[k].startActivityNotificationId},",
          );
        }
      }
    }
  }
}
