// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:chain_events/models/chain_event.dart';
import 'package:flutter/material.dart';
import 'package:chain_events/helpers/constants.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:chain_events/helpers/ad_state.dart';
import 'package:chain_events/helpers/db_helper.dart';
import 'package:chain_events/helpers/key_helper.dart';
import 'package:chain_events/helpers/notification_helper.dart';

import 'package:chain_events/models/event.dart';
import 'package:chain_events/models/chain.dart';
import 'package:chain_events/models/system_setting.dart';
import 'package:chain_events/screens/play_chain_screen.dart';
import 'package:uuid/uuid.dart';
//import 'package:chain_events/screens/play_chain_screen.dart';

/*

Table of Content for Functions defined in this class
Chain:
	addChain
	removeChain
	-> updateSchdule
	rearrangeChains
	pinChain
	fetchChains

Event:
	-> addEvent .. no need as of now.
	removeEvent
	updateEvent
	rearrangeActivites
	updateEventIndex
	flipDoneEvent
	loadActivities
	fetchActivities

Util:
	clearDataBase
	disposeAds

*/

class ChainList with ChangeNotifier {
  bool loaded = false;
  List<Chain> chains = [];
  List<Event> activities = [];
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
    await fetchChains();
    await fetchActivities();
    await fetchSettings();
    KeyHelper.navigatorKey = GlobalKey<NavigatorState>();
    await notificationHelper.initialize(systemSettings);
    for (int chainId = 0; chainId < chains.length; chainId++) {
      if (chains[chainId].notificationId == noValueInDB) {
        continue;
      }
      notificationIdsInDB.add(chains[chainId].notificationId);
      Chain sch = chains[chainId];
      for (int eventId = 0; eventId < sch.activities.length; eventId++) {
        if (sch.activities[eventId].startEventNotificationId == noValueInDB) {
          continue;
        }
        notificationIdsInDB
            .add(sch.activities[eventId].startEventNotificationId);
        if (sch.activities[eventId].endEventNotificationId == noValueInDB) {
          continue;
        }
        notificationIdsInDB.add(sch.activities[eventId].endEventNotificationId);
      }
    }

    notificationCameAs = await notificationHelper.localNotificationService
        .checkForNotification();

    loaded = true;
    notifyListeners();
  }

  Future<void> addChain(Chain chain, ChainEvent chainEvent) async {
    int chainIndex = chains.indexWhere((sch) => sch.title == chain.title);

    if (chainIndex == -1) {
      chain.index = chains.length;
      chains.add(chain);
    } else {
      chain.index = chainIndex;
      chains[chainIndex] = chain;
    }

    int eventIndex =
        activities.indexWhere((act) => act.title == chainEvent.event.title);

    if (eventIndex == -1) {
      activities.add(chainEvent.event);
    } else {
      chainEvent.event = activities[eventIndex];
    }

    chainEvent.index = chain.activities.length;

    if (eventIndex == -1) {
      await DBHelper.insert(
        "event",
        {
          "eventId": chainEvent.event.eventId,
          "title": chainEvent.event.title,
          "type": chainEvent.event.type,
          "createdAt": chainEvent.event.createdAt.millisecondsSinceEpoch,
          "lastUpdatedAt":
              chainEvent.event.lastUpdatedAt.millisecondsSinceEpoch,
          "edit": chainEvent.event.edit ? 1 : 0,
        },
      );
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
      "chain_event",
      {
        "title": chain.title,
        "eventId": chainEvent.event.eventId,
        "eventIndex": chainEvent.index,
        "eventDone": chainEvent.eventDone ? trueInDB : falseInDB,
        "isInterrupted": chainEvent.isInterrupted ? trueInDB : falseInDB,
        "notificationId": jsonEncode({
          "startEventNotificationId": chainEvent.startEventNotificationId,
          "endEventNotificationId": chainEvent.endEventNotificationId,
        }),
        "eventDuration": chainEvent.eventDuration.inSeconds,
        "repeatType": chainEvent.repeatType,
        "repeatTypeGap": chainEvent.repeatTypeGap,
        "repeatCount": chainEvent.repeatCount,
        "startedAt": chainEvent.at == null
            ? noValueInDB
            : chainEvent.at!.millisecondsSinceEpoch,
        "eventDurationLeft": chainEvent.eventDurationLeft == null
            ? noValueInDB
            : chainEvent.eventDurationLeft!.inSeconds,
        "endedAt": chainEvent.endedAt == null
            ? noValueInDB
            : chainEvent.endedAt!.millisecondsSinceEpoch,
        "editChainEvent": chainEvent.edit ? 1 : 0,
      },
    );
    // }
    notifyListeners();
  }

  Future<void> removeChain(Chain chain) async {
    chains.removeWhere((sch) => sch.title == chain.title);
    await cancelScheduledNotification(chain);

    await DBHelper.removeData(
      "chain_event",
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
      },
      "title = ?",
      [oldChainTitle],
    );

    await DBHelper.update(
      "chain_event",
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
      "chain_event_execution",
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
        "endedAt":
            chainExecution.endedAt?.millisecondsSinceEpoch ?? noValueInDB,
        "notificationId": chainExecution.notificationId,
        "chainStatus": chainExecution.chainStatus,
        "repeatType": chainExecution.repeatType,
        "repeatTypeGap": chainExecution.repeatTypeGap,
        "repeatCount": chainExecution.repeatCount,
      },
    );

    //int chainEventIndex = 0;

    for (ChainEvent chainEvent in chainExecution.activities) {
      await DBHelper.insert(
        "chain_event_execution",
        {
          "chainExecutionId": chainExecution.chainExecutionId,
          "title": chainExecution.title,
          "eventId": chainEvent.event.eventId,
          "eventIndex": chainEvent.index,
          "eventDone": chainEvent.eventDone ? trueInDB : falseInDB,
          "isInterrupted": chainEvent.isInterrupted ? trueInDB : falseInDB,
          "notificationId": jsonEncode({
            "startEventNotificationId": chainEvent.startEventNotificationId,
            "endEventNotificationId": chainEvent.endEventNotificationId,
          }),
          "eventDuration": chainEvent.eventDuration.inSeconds,
          "repeatType": chainEvent.repeatType,
          "repeatTypeGap": chainEvent.repeatTypeGap,
          "repeatCount": chainEvent.repeatCount,
          "startedAt": chainEvent.at == null
              ? noValueInDB
              : chainEvent.at!.millisecondsSinceEpoch,
          "eventDurationLeft": chainEvent.eventDurationLeft == null
              ? noValueInDB
              : chainEvent.eventDurationLeft!.inSeconds,
          "endedAt": chainEvent.endedAt == null
              ? noValueInDB
              : chainEvent.endedAt!.millisecondsSinceEpoch,
        },
      );
      //chainEventIndex++;
    }
  }

  DateTime? getNextStartDateTime(DateTime currentStartDate, String repeatType,
      int repeatTypeGap, int repeatCount) {
    DateTime newStartDate = currentStartDate;
    do {
      switch (repeatType) {
        case repeatTypeSecond:
          newStartDate = newStartDate.add(
            Duration(seconds: repeatTypeGap),
          );
          break;
        case repeatTypeMinute:
          newStartDate = newStartDate.add(
            Duration(minutes: repeatTypeGap),
          );
          break;
        case repeatTypeHourly:
          newStartDate = newStartDate.add(
            Duration(hours: repeatTypeGap),
          );
          break;
        case repeatTypeDaily:
          newStartDate = newStartDate.add(
            Duration(days: repeatTypeGap),
          );
          break;
        case repeatTypeWeekly:
          newStartDate = DateTime(
            newStartDate.year,
            newStartDate.month,
            newStartDate.day + (7 * repeatTypeGap),
            newStartDate.hour,
            newStartDate.minute,
            newStartDate.second,
          );
          break;
        case repeatTypeMonthly:
          newStartDate = DateTime(
            newStartDate.year,
            newStartDate.month + repeatTypeGap,
            newStartDate.day,
            newStartDate.hour,
            newStartDate.minute,
            newStartDate.second,
          );
          break;
        case repeatTypeYearly:
          newStartDate = DateTime(
            newStartDate.year + repeatTypeGap,
            newStartDate.month,
            newStartDate.day,
            newStartDate.hour,
            newStartDate.minute,
            newStartDate.second,
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
    chainExecution.endedAt = null;
    chainExecution.chainStatus = statusDone;
    chainExecution.notificationId = chain.notificationId;
    chainExecution.chainStatus = statusExecuting;
    chainExecution.index = chain.index;
    chainExecution.repeatType = chain.repeatType;
    chainExecution.repeatTypeGap = chain.repeatTypeGap;
    chainExecution.repeatCount = chain.repeatCount;

    for (ChainEvent chainEvent in chain.activities) {
      ChainEvent chainEventCopy = ChainEvent(
        event: chainEvent.event,
        eventDone: chainEvent.eventDone,
        eventDuration: chainEvent.eventDuration,
      );
      if (chainEventCopy.event.type == systemStartEventInDB) {
        chainEventCopy.repeatType = chainExecution.repeatType;
        chainEventCopy.repeatTypeGap = chainExecution.repeatTypeGap;
        chainEventCopy.repeatCount = chainExecution.repeatCount;
        //chainEventCopy.at = chainExecution.at;
      }
      chainEventCopy.at = null;
      chainEventCopy.eventDurationLeft = null;
      chainEventCopy.endedAt = null;
      chainEventCopy.isInterrupted = false;
      chainEventCopy.edit = false;
      chainEventCopy.startEventNotificationId =
          chainEvent.startEventNotificationId;
      chainEventCopy.endEventNotificationId = chainEvent.endEventNotificationId;
      chainEventCopy.index = chainEvent.index;
      chainExecution.activities.add(chainEventCopy);
    }

    await addChainToHistory(chainExecution);
    int chainIndex = chains.indexWhere((sch) => sch.title == chain.title);

    chains[chainIndex].chainHistory.insert(0, chainExecution);
    chains[chainIndex].endedAt = null;
    if (chains[chainIndex].repeatType != repeatTypeDoesNotRepeat) {
      chains[chainIndex].at = getNextStartDateTime(
        chains[chainIndex].at!,
        chains[chainIndex].repeatType,
        chains[chainIndex].repeatTypeGap,
        chains[chainIndex].repeatCount,
      );
    }
    if (chains[chainIndex].repeatCount != -1) {
      chains[chainIndex].repeatCount--;
    }
    if (chains[chainIndex].repeatCount == 0) {
      chains[chainIndex].repeatType = repeatTypeDoesNotRepeat;
      chains[chainIndex].at = null;
    }

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

  Future<void> stopChainExecution(Chain chain) async {
    int executingChainIndex = chain.chainHistory
        .indexWhere((sch) => sch.chainStatus == statusExecuting);
    if (executingChainIndex != -1) {
      await cancelScheduleNotificationExecution(
          chain.chainHistory[executingChainIndex]);
      await resetChainExecution(chain.chainHistory[executingChainIndex]);
      await resetChain(chain);
    }
  }

  Future<void> updateChain(Chain chain) async {
    int chainIndex = chains.indexWhere((sch) => sch.title == chain.title);

    if (chainIndex == -1) {
      return;
    }
    chains[chainIndex] = chain;

    await DBHelper.update(
      "chain",
      {
        "lastUpdatedAt": chain.lastUpdatedAt.millisecondsSinceEpoch,
        "pinned": chain.pinned,
        "startedAt":
            chain.at != null ? chain.at!.millisecondsSinceEpoch : noValueInDB,
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

  Future<void> updateChainEventByEventId(
      Chain chain, ChainEvent chainEvent) async {
    await DBHelper.update(
      "chain_event",
      {
        "eventDone": chainEvent.eventDone ? trueInDB : falseInDB,
        "isInterrupted": chainEvent.isInterrupted ? trueInDB : falseInDB,
        "notificationId": jsonEncode({
          "startEventNotificationId": chainEvent.startEventNotificationId,
          "endEventNotificationId": chainEvent.endEventNotificationId,
        }),
        "eventDuration": chainEvent.eventDuration.inSeconds,
        "repeatType": chainEvent.repeatType,
        "repeatTypeGap": chainEvent.repeatTypeGap,
        "repeatCount": chainEvent.repeatCount,
        "startedAt": chainEvent.at != null
            ? chainEvent.at!.millisecondsSinceEpoch
            : noValueInDB,
        "eventDurationLeft": chainEvent.eventDurationLeft != null
            ? chainEvent.eventDurationLeft!.inSeconds
            : noValueInDB,
        "endedAt": chainEvent.endedAt != null
            ? chainEvent.endedAt!.millisecondsSinceEpoch
            : noValueInDB,
        "editChainEvent": chainEvent.edit ? 1 : 0,
      },
      "title = ? and eventId = ? and eventIndex = ?",
      [
        chain.title,
        chainEvent.event.eventId,
        chainEvent.index,
      ],
    );
    notifyListeners();
  }

  Future<void> updatChainEventByChainName(
    Chain chain, [
    bool editChainEvent = false,
  ]) async {
    await DBHelper.update(
      "chain_event",
      {
        // "eventDone": chain.chainStatus,
        // "isInterrupted": chain.chainStatus,
        "editChainEvent": editChainEvent,
      },
      "title = ?",
      [chain.title],
    );
    notifyListeners();
  }

  Future<void> updateChainEventExecutionByEventId(
      Chain chain, ChainEvent chainEvent) async {
    await DBHelper.update(
      "chain_event_execution",
      {
        "eventDone": chainEvent.eventDone ? trueInDB : falseInDB,
        "isInterrupted": chainEvent.isInterrupted ? trueInDB : falseInDB,
        "notificationId": jsonEncode({
          "startEventNotificationId": chainEvent.startEventNotificationId,
          "endEventNotificationId": chainEvent.endEventNotificationId,
        }),
        "eventDuration": chainEvent.eventDuration.inSeconds,
        "repeatType": chainEvent.repeatType,
        "repeatTypeGap": chainEvent.repeatTypeGap,
        "repeatCount": chainEvent.repeatCount,
        "startedAt": chainEvent.at != null
            ? chainEvent.at!.millisecondsSinceEpoch
            : noValueInDB,
        "eventDurationLeft": chainEvent.eventDurationLeft != null
            ? chainEvent.eventDurationLeft!.inSeconds
            : noValueInDB,
        "endedAt": chainEvent.endedAt != null
            ? chainEvent.endedAt!.millisecondsSinceEpoch
            : noValueInDB,
      },
      "chainExecutionId = ? and title = ? and eventId = ? and eventIndex = ?",
      [
        chain.chainExecutionId,
        chain.title,
        chainEvent.event.eventId,
        chainEvent.index,
      ],
    );
    notifyListeners();
  }

  Future<void> resetChain(Chain chain) async {
    await cancelScheduledNotification(chain);

    for (ChainEvent event in chain.activities) {
      event.edit = false;
      event.eventDone = false;
      event.isInterrupted = false;
      event.at = null;
      event.endedAt = null;
    }

    await DBHelper.update(
      "chain_event",
      {
        "eventDone": statusNotStarted,
        "isInterrupted": statusNotStarted,
        "startedAt": noValueInDB,
        "eventDurationLeft": noValueInDB,
        "endedAt": noValueInDB,
        "editChainEvent": 0,
      },
      "title = ?",
      [chain.title],
    );

    chain.at = chain.endedAt = null;
    chain.notificationId = noValueInDB;
    chain.chainStatus = statusNotStarted;
    chain.repeatType = repeatTypeDoesNotRepeat;
    chain.repeatTypeGap = repeatTypeDefaultGap;
    chain.repeatCount = repeatTypeDefaultCount;
    await updateChain(chain);

    notifyListeners();
  }

  Future<void> resetChainExecution(Chain chainExecution) async {
    await cancelScheduleNotificationExecution(chainExecution);

    int indexOfChain =
        chains.indexWhere((sch) => sch.title == chainExecution.title);

    chains[indexOfChain].chainHistory.removeWhere(
        (schEx) => schEx.chainExecutionId == chainExecution.chainExecutionId);

    await DBHelper.removeData("chain_event_execution", "chainExecutionId = ?",
        [chainExecution.chainExecutionId]);

    notifyListeners();
  }

  Future<void> removeEventFromChain(Chain chain, ChainEvent chainEvent) async {
    //chains.removeWhere((sc) => sc.name == chain.name);

    //Cancel Notification
    if (chainEvent.startEventNotificationId != noValueInDB) {
      await notificationHelper
          .cancelNotificationById(chainEvent.startEventNotificationId);
    }

    if (chainEvent.endEventNotificationId != noValueInDB) {
      await notificationHelper
          .cancelNotificationById(chainEvent.endEventNotificationId);
    }

    await DBHelper.removeData(
      "chain_event",
      "title = ? and eventId = ? and eventIndex = ?",
      [chain.title, chainEvent.event.eventId, chainEvent.index],
    );
    await DBHelper.removeData(
      "chain_event",
      "title = ? and eventIndex = ?",
      [
        chain.title,
        chainEvent.index + 1,
      ],
    );

    int indexOfChainEvent = chain.activities.indexWhere(
        (eventArg) => eventArg.event.eventId == chainEvent.event.eventId);

    chain.activities.removeAt(indexOfChainEvent);
    chain.activities.removeAt(indexOfChainEvent);

    if (chain.activities.length == 1) {
      ChainEvent startChainEvent = chain.activities[0];
      await DBHelper.removeData(
        "chain_event",
        "title = ? and eventIndex = ?",
        [
          chain.title,
          startChainEvent.index,
        ],
      );
      chain.activities = [];
    }

    updateEventIndex(chain);

    notifyListeners();
  }

  Future<void> removeEvent(Event event) async {
    DBHelper.removeData(
      "event",
      "eventId = ?",
      [event.eventId],
    );
  }

  Future<void> updateEvent(Event event) async {
    await DBHelper.update(
      "event",
      {
        "title": event.title,
        "type": event.type,
        "lastUpdatedAt": event.lastUpdatedAt.millisecondsSinceEpoch,
        "edit": event.edit ? 1 : 0,
      },
      "eventId = ?",
      [event.eventId],
    );
    notifyListeners();
  }

  /* Just for testing */
  Future<void> clearDataBase() async {
    await DBHelper.removeData('chain_event_execution', "", []);
    await DBHelper.removeData('chain_execution', "", []);
    await DBHelper.removeData('chain_event', "", []);
    await DBHelper.removeData('event', "", []);
    await DBHelper.removeData('chain', "", []);
    setSetting("DARK THEME", "FALSE");
    setSetting("Notification Type", "App Notification,None");
    setSetting("App Sound", "TRUE");
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

    if (chain.activities[newIndex].event.title == systemWaitEventTitle) {
      if (oldIndex > newIndex) {
        newIndex += 1;
      } else {
        newIndex -= 1;
      }
    }

    if (oldIndex < newIndex) {
      ChainEvent tempEvent = chain.activities[oldIndex];
      for (int i = oldIndex; i < newIndex; i += 2) {
        chain.activities[i] = chain.activities[i + 2];
      }
      chain.activities[newIndex] = tempEvent;
    } else {
      ChainEvent tempEvent = chain.activities[oldIndex];
      for (int i = oldIndex; i > newIndex; i -= 2) {
        chain.activities[i] = chain.activities[i - 2];
      }
      chain.activities[newIndex] = tempEvent;
    }

    // if (chain.activities[newIndex].event.title ==
    //     systemWaitEventTitle) {
    //   if (oldIndex > newIndex) {
    //     newIndex += 1;
    //   } else {
    //     newIndex -= 1;
    //   }
    // }

    // if (chain.activities[oldIndex].event.title ==
    //     systemWaitEventTitle) {
    //   if (oldIndex > newIndex) {
    //     oldIndex -= 1;
    //   } else {
    //     oldIndex += 1;
    //   }
    // }

    // var itemAtOldIndex = chain.activities.removeAt(oldIndex);
    // chain.activities.insert(newIndex, itemAtOldIndex);

    await updateEventIndex(chain);
    notifyListeners();
  }

  //helper function
  Future<void> updateEventIndex(Chain chain) async {
    int dbIndex = 0;
    for (ChainEvent chainEvent in chain.activities) {
      // if (chainEvent.event.title == systemWaitEventTitle) {
      //   continue;
      // }
      await DBHelper.update(
        "chain_event",
        {
          "eventIndex": dbIndex,
        },
        "title = ? and eventId = ? and eventIndex = ?",
        [chain.title, chainEvent.event.eventId, chainEvent.index],
      );
      chainEvent.index = dbIndex;
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

  Future<void> flipDoneEvent(Chain chain, ChainEvent chainEvent) async {
    chainEvent.eventDone = !chainEvent.eventDone;
    if (chainEvent.endedAt == null) {
      chainEvent.endedAt = DateTime.now();
      chainEvent.eventDurationLeft = null;
    } else {
      chainEvent.endedAt = null;
    }

    await updateChainEventExecutionByEventId(
      chain,
      chainEvent,
    );

    notifyListeners();
  }

  Future<void> flipDoneRestAfterEvent(
      Chain chain, ChainEvent chainEvent) async {
    chainEvent.isInterrupted = !chainEvent.isInterrupted;
    if (chainEvent.endedAt == null) {
      chainEvent.endedAt = DateTime.now();
    } else {
      chainEvent.endedAt = null;
    }
    await updateChainEventExecutionByEventId(
      chain,
      chainEvent,
    );

    notifyListeners();
  }

  Future<void> playNotificationSound() async {
    await notificationHelper.playNotificationSound();
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

  Future<List<ChainEvent>> loadActivities(Chain chain) async {
    List<Map<String, dynamic>> loadedChainEvent = await DBHelper.getDataBySQL(
      '''
      SELECT chain_event.*, event.*
      FROM chain_event
      JOIN event ON (chain_event.eventId = event.eventId)
      WHERE chain_event.title = ?
      ORDER BY chain_event.eventIndex
      ''',
      [chain.title],
    );
    chain.activities = [];
    for (var chainEvent in loadedChainEvent) {
      ChainEvent tempEvent = ChainEvent(
        event: Event(
          eventId: chainEvent['eventId'],
          title: chainEvent['title'],
          createdAt:
              DateTime.fromMillisecondsSinceEpoch(chainEvent["createdAt"]),
          lastUpdatedAt:
              DateTime.fromMillisecondsSinceEpoch(chainEvent["lastUpdatedAt"]),
          type: chainEvent['type'],
        ),
        eventDone: chainEvent['eventDone'] == 1,
        eventDuration: Duration(seconds: chainEvent['eventDuration']),
        repeatType: chainEvent['repeatType'] ?? repeatTypeDoesNotRepeat,
        repeatTypeGap: chainEvent['repeatTypeGap'] ?? repeatTypeDefaultGap,
        repeatCount: chainEvent['repeatCount'] ?? repeatTypeDefaultCount,
      );
      tempEvent.isInterrupted = chainEvent['isInterrupted'] == 1;
      tempEvent.at = getDateValueFromDB(chainEvent["startedAt"]);
      tempEvent.eventDurationLeft = chainEvent['eventDurationLeft'] == null ||
              chainEvent['eventDurationLeft'] == noValueInDB
          ? null
          : Duration(seconds: chainEvent['eventDurationLeft']);
      tempEvent.endedAt = getDateValueFromDB(chainEvent["endedAt"]);
      tempEvent.event.edit = chainEvent['edit'] == 1;
      tempEvent.edit = chainEvent['editChainEvent'] == 1;
      Map<String, dynamic>? notifications =
          jsonDecode(chainEvent['notificationId']);
      if (notifications != null) {
        tempEvent.startEventNotificationId =
            notifications["startEventNotificationId"];
        tempEvent.endEventNotificationId =
            notifications["endEventNotificationId"];
      }

      tempEvent.index = chainEvent['eventIndex'];
      chain.activities.add(tempEvent);
    }
    return chain.activities;
  }

  Future<Event?> getEventByEventId(String eventId) async {
    List<Map<String, dynamic>> eventFromDB =
        await DBHelper.getData('event', 'eventId', 'eventId = ?', [eventId]);
    if (eventFromDB.isEmpty) {
      return null;
    }
    return Event(
      eventId: eventFromDB[0]['eventId'],
      title: eventFromDB[0]['title'],
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(eventFromDB[0]["createdAt"]),
      lastUpdatedAt:
          DateTime.fromMillisecondsSinceEpoch(eventFromDB[0]["lastUpdatedAt"]),
      type: eventFromDB[0]['type'],
    );
  }

  Future<List<ChainEvent>> loadChainEventHistory(Chain chainExecution) async {
    List<Map<String, dynamic>> loadedChainEventHistory = await DBHelper.getData(
      "chain_event_execution",
      "eventIndex",
      "chainExecutionId = ?",
      [
        chainExecution.chainExecutionId,
      ],
    );

    List<ChainEvent> result = [];
    for (var chainEvent in loadedChainEventHistory) {
      Event? eventRetrieved = await getEventByEventId(chainEvent['eventId']);
      if (eventRetrieved == null) {
        continue;
      }
      ChainEvent tempEvent = ChainEvent(
        event: eventRetrieved,
        eventDone: chainEvent['eventDone'] == statusDone,
        eventDuration: Duration(seconds: chainEvent['eventDuration']),
        repeatType: chainEvent['repeatType'] ?? repeatTypeDoesNotRepeat,
        repeatTypeGap: chainEvent['repeatTypeGap'] ?? repeatTypeDefaultGap,
        repeatCount: chainEvent['repeatCount'] ?? repeatTypeDefaultCount,
      );
      tempEvent.isInterrupted = chainEvent['isInterrupted'] == statusDone;
      tempEvent.at = getDateValueFromDB(chainEvent["startedAt"]);
      tempEvent.eventDurationLeft = chainEvent['eventDurationLeft'] == null ||
              chainEvent['eventDurationLeft'] == noValueInDB
          ? null
          : Duration(seconds: chainEvent['eventDurationLeft']);
      tempEvent.endedAt = getDateValueFromDB(chainEvent["endedAt"]);

      Map<String, dynamic>? notifications =
          jsonDecode(chainEvent['notificationId']);
      if (notifications != null) {
        tempEvent.startEventNotificationId =
            notifications["startEventNotificationId"];
        tempEvent.endEventNotificationId =
            notifications["endEventNotificationId"];
      }
      tempEvent.index = chainEvent['eventIndex'];
      result.add(tempEvent);
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
      chainExecution.endedAt = getDateValueFromDB(chainHistory["endedAt"]);
      chainExecution.chainStatus = chainHistory['chainStatus'];
      chainExecution.notificationId = int.parse(chainHistory["notificationId"]);
      chainExecution.activities = await loadChainEventHistory(chainExecution);
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

  Future<List<Event>> fetchActivities() async {
    List<Map<String, dynamic>> loadedActivities =
        await DBHelper.getData("event", "eventId");

    activities = [];

    for (var event in loadedActivities) {
      Event tempEvent = Event(
        eventId: event["eventId"],
        title: event["title"],
        createdAt: DateTime.fromMillisecondsSinceEpoch(event["createdAt"]),
        lastUpdatedAt:
            DateTime.fromMillisecondsSinceEpoch(event["lastUpdatedAt"]),
        type: event["type"],
      );
      // tempEvent.eventDuration =
      //     Duration(seconds: event["eventDuration"] ?? 0);
      // tempEvent.repeatType =
      //     Duration(seconds: event["repeatType"] ?? 0);
      // tempEvent.at = getDateValueFromDB(event["startedAt"]);
      // tempEvent.endedAt = getDateValueFromDB(event["endedAt"]);
      tempEvent.edit = event["edit"] == 1;
      activities.insert(0, tempEvent);
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

  Future<void> scheduleNotificationForExecution(
    Chain chain,
    DateTime fromDateTime,
  ) async {
    int countOfActivities = chain.activities.length;
    for (int i = 0; i < countOfActivities; i++) {
      if (chain.activities[i].endedAt != null) {
        continue;
      }
      if (chain.activities[i].event.type == systemWaitEventInDB) {
        fromDateTime = fromDateTime.add(chain.activities[i].eventDuration);
        fromDateTime = fromDateTime.add(const Duration(microseconds: 1));
        continue;
      }
      int nextNotificationId = getNextNotificationId();
      String eventTitle = chain.activities[i].event.title;

      if (chain.activities[i].event.type == systemStartEventInDB) {
        //chain.notificationId = nextNotificationId;
        eventTitle = "Chain of Events '${chain.title}'";
        //await updateChainExecution(chain);
      }
      if (chain.activities[i].startEventNotificationId == noValueInDB) {
        notificationHelper.cancelNotificationById(
            chain.activities[i].startEventNotificationId);
      }
      chain.activities[i].startEventNotificationId =
          await notificationHelper.scheduleNotification(
        fromDateTime,
        nextNotificationId,
        chain.title,
        "$eventTitle has Started.",
        {
          payLoadChainName: chain.title,
          payLoadChainExecId: chain.chainExecutionId,
          payLoadWidgetUrl: PlayChain.routename,
          payLoadChainEventIndex: i + 1,
          payLoadChainEventCount: chain.activities.length,
        },
      );

      await updateChainEventExecutionByEventId(
        chain,
        chain.activities[i],
      );

      if (chain.activities[i].event.type != systemWaitEventInDB &&
          chain.activities[i].event.type != systemStartEventInDB &&
          (chain.activities[i].eventDuration.inSeconds == 0 ||
              (chain.activities[i].eventDurationLeft != null &&
                  chain.activities[i].eventDurationLeft!.inSeconds > 0))) {
        break;
      }
      DateTime dateTimeAfterDurationAddition =
          fromDateTime.add(chain.activities[i].eventDuration);
      if (fromDateTime == dateTimeAfterDurationAddition) {
        fromDateTime = fromDateTime.add(const Duration(microseconds: 1));
        continue;
      }
      fromDateTime = dateTimeAfterDurationAddition;

      // Schedule Event end notification
      nextNotificationId = getNextNotificationId();
      if (i == (countOfActivities - 2)) {
        eventTitle = "Chain of Events '${chain.title}'";
      }
      if (chain.activities[i].endEventNotificationId != noValueInDB) {
        notificationHelper
            .cancelNotificationById(chain.activities[i].endEventNotificationId);
      }
      chain.activities[i].endEventNotificationId =
          await notificationHelper.scheduleNotification(
        fromDateTime,
        nextNotificationId,
        chain.title,
        "$eventTitle has Ended.",
        {
          payLoadChainName: chain.title,
          payLoadChainExecId: chain.chainExecutionId,
          payLoadWidgetUrl: PlayChain.routename,
          payLoadChainEventIndex: i + 2,
          payLoadChainEventCount: chain.activities.length,
        },
      );

      await updateChainEventExecutionByEventId(
        chain,
        chain.activities[i],
      );
      fromDateTime = fromDateTime.add(const Duration(microseconds: 1));
    }
    notifyListeners();
  }

  Future<void> cancelScheduleNotificationExecution(Chain chain) async {
    //Cancel Notifications
    await cancelScheduledNotification(chain);
    for (ChainEvent chainEvent in chain.activities) {
      if (chainEvent.startEventNotificationId != noValueInDB) {
        await notificationHelper
            .cancelNotificationById(chainEvent.startEventNotificationId);
        chainEvent.startEventNotificationId = noValueInDB;
      }
      if (chainEvent.endEventNotificationId != noValueInDB) {
        await notificationHelper
            .cancelNotificationById(chainEvent.endEventNotificationId);
        chainEvent.endEventNotificationId = noValueInDB;
      }
      await updateChainEventExecutionByEventId(chain, chainEvent);
    }

    // await DBHelper.update(
    //   "chain_event",
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
      await notificationHelper.cancelNotificationById(chain.notificationId);
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
            "Start Notification for Event ${chains[i].chainHistory[j].activities[k].event.title} is ${chains[i].chainHistory[j].activities[k].startEventNotificationId},",
          );
          print(
            "End Notification for Event ${chains[i].chainHistory[j].activities[k].event.title} is ${chains[i].chainHistory[j].activities[k].startEventNotificationId},",
          );
        }
      }
    }
  }
}
