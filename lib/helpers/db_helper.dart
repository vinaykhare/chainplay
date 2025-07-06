import 'dart:convert';

import 'package:chain_activities/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  // Private constructor to prevent external instantiation.
  DBHelper._();

  // The single instance of the class.
  static final DBHelper _dBHelperInstance = DBHelper._();

  // Factory constructor to provide access to the singleton instance.
  factory DBHelper() {
    return _dBHelperInstance;
  }

  //Methods & Properties

  SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  Future<SharedPreferencesAsync> initializeSharedPrefDatabase() async {
    bool sharedPrefDBHasSetting = await asyncPrefs.containsKey("settings");
    bool sharedPrefDBHasActivity = await asyncPrefs.containsKey("activity");
    bool sharedPrefDBHasChain = await asyncPrefs.containsKey("chain");
    bool sharedPrefDBHasChainExecution =
        await asyncPrefs.containsKey("chain_execution");
    bool sharedPrefDBHasChainActivity =
        await asyncPrefs.containsKey("chain_activity");
    bool sharedPrefDBHasChainActivityExecution =
        await asyncPrefs.containsKey("chain_activity_execution");

    if (!sharedPrefDBHasActivity) {
      asyncPrefs.setStringList("activity", []);
    }
    if (!sharedPrefDBHasChain) {
      asyncPrefs.setStringList("chain", []);
    }
    if (!sharedPrefDBHasChainExecution) {
      asyncPrefs.setStringList("chain_execution", []);
    }
    if (!sharedPrefDBHasChainActivity) {
      asyncPrefs.setStringList("chain_activity", []);
    }
    if (!sharedPrefDBHasChainActivityExecution) {
      asyncPrefs.setStringList("chain_activity_execution", []);
    }

    if (!sharedPrefDBHasSetting) {
      List<String> defaultEncodedSetting = [
        jsonEncode({
          "key": darkThemeSettingKey,
          "value": falseSettingValue,
          "type": settingDataTypeBool,
        }),
        jsonEncode({
          "key": appSoundSettingKey,
          "value": trueSettingValue,
          "type": settingDataTypeBool,
        }),
        jsonEncode({
          "key": showHelpOnNextBootKey,
          "value": trueSettingValue,
          "type": settingDataTypeBool,
        }),
      ];
      asyncPrefs.setStringList("settings", defaultEncodedSetting);
    }
    return asyncPrefs;
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    insertInSharedPrefDatabase(table, data);
  }

  Future<void> insertInSharedPrefDatabase(
      String table, Map<String, dynamic> data) async {
    List<String> tableContent = await asyncPrefs.getStringList(table) ?? [];
    tableContent.add(jsonEncode(data));
    asyncPrefs.setStringList(table, tableContent);
    return;
  }

  Future<void> update(String table, Map<String, dynamic> data, String condition,
      List<dynamic> conditionArgs) async {
    updateInSharedPrefDatabase(table, data, condition, conditionArgs);
  }

  Future<void> updateInSharedPrefDatabase(
      String table,
      Map<String, dynamic> data,
      String condition,
      List<dynamic> conditionArgs) async {
    List<String> tableContent = await asyncPrefs.getStringList(table) ?? [];
    int requrestedRow = tableContent.indexWhere((String entry) {
      Map<String, dynamic> objectEntry = jsonDecode(entry);
      return objectEntry[condition.split("=").first.trim()] == conditionArgs[0];
    });
    if (requrestedRow == -1) {
      return;
    }
    Map<String, dynamic> objectEntry = jsonDecode(tableContent[requrestedRow]);

    tableContent.removeAt(requrestedRow);
    // update objectEntry
    data.forEach((key, value) {
      objectEntry[key] = value;
    });
    tableContent.add(jsonEncode(objectEntry));
    asyncPrefs.setStringList(table, tableContent);
    return;
  }

  Future<List<Map<String, dynamic>>> getData(String table, String orderBy,
      [String condition = "", List<dynamic> conditionArgs = const []]) async {
    List<Map<String, dynamic>> result = [];
    result =
        await getDataFromSharedPref(table, orderBy, condition, conditionArgs);
    return result;
  }

  Future<List<Map<String, dynamic>>> getDataFromSharedPref(
      String table, String orderBy,
      [String condition = "", List<dynamic> conditionArgs = const []]) async {
    List<Map<String, dynamic>> result = [];

    List<String> tableContent = await asyncPrefs.getStringList(table) ?? [];

    List<String> conditionParams = condition.split("= ?");

    List<String> filteredTable = tableContent.where((String entry) {
      Map<String, dynamic> objectEntry = jsonDecode(entry);
      bool match = false;
      for (int i = 0; i < conditionArgs.length; i++) {
        if (conditionParams[i].trim().startsWith("or")) {
          match = match ||
              objectEntry[conditionParams[i].trim().substring(3)] ==
                  conditionArgs[i];
        } else if (conditionParams[i].trim().startsWith("and")) {
          match = match &&
              objectEntry[conditionParams[i].trim().substring(4)] ==
                  conditionArgs[i];
        } else {
          match = match ||
              objectEntry[conditionParams[i].trim()] == conditionArgs[i];
        }
      }
      return match;
    }).toList();

    filteredTable.map((String entry) {
      result.add(jsonDecode(entry));
    }).toList();

    return result;
  }

  Future<List<Map<String, dynamic>>> getJointResultFromSharedPref(
      List<String> tables,
      String joinBy,
      List<String> conditionParams,
      List<dynamic> conditionArgs,
      String orderBy) async {
    List<String> primaryTableRawContent =
        await asyncPrefs.getStringList(tables[0]) ?? [];
    List<Map<String, dynamic>> jointTableContent = [];

    for (int primaryTableRawContentIndex = 0;
        primaryTableRawContentIndex < primaryTableRawContent.length;
        primaryTableRawContentIndex++) {
      Map<String, dynamic> primaryTableContentEntry =
          jsonDecode(primaryTableRawContent[primaryTableRawContentIndex]);

      for (int tableIndex = 1; tableIndex < tables.length; tableIndex++) {
        List<String> tableRawContent =
            await asyncPrefs.getStringList(tables[tableIndex]) ?? [];
        for (int tableRawContentIndex = 0;
            tableRawContentIndex < tableRawContent.length;
            tableRawContentIndex++) {
          Map<String, dynamic> tableContentEntry =
              jsonDecode(tableRawContent[tableRawContentIndex]);
          if (tableContentEntry[joinBy] == primaryTableContentEntry[joinBy]) {
            jointTableContent.add({
              ...primaryTableContentEntry,
              ...tableContentEntry,
            });
          }
        }
      }
    }

    for (int conditionArgsIndex = 0;
        conditionArgsIndex < conditionArgs.length;
        conditionArgsIndex++) {
      jointTableContent = jointTableContent.where((Map<String, dynamic> entry) {
        return entry[conditionParams[conditionArgsIndex]] ==
            conditionArgs[conditionArgsIndex];
      }).toList();
    }

    return jointTableContent;
  }

  Future<List<Map<String, dynamic>>> getJointResult(
      List<String> tables,
      String joinBy,
      List<String> conditionParams,
      List<dynamic> conditionArgs,
      String orderBy) async {
    List<Map<String, dynamic>> result = [];

    result = await getJointResultFromSharedPref(
        tables, joinBy, conditionParams, conditionArgs, orderBy);

    return result;
  }

  Future<void> removeData(
      String table, String condition, List<dynamic> conditionArgs) async {
    return removeDataFromSharedPref(table, condition, conditionArgs);
  }

  Future<void> removeDataFromSharedPref(
      String table, String condition, List<dynamic> conditionArgs) async {
    try {
      List<String> tableContent = await asyncPrefs.getStringList(table) ?? [];
      tableContent.removeWhere((String entry) {
        Map<String, dynamic> objectEntry = jsonDecode(entry);
        return objectEntry[condition.split("=").first.trim()] ==
            conditionArgs[0];
      });

      asyncPrefs.setStringList(table, tableContent);

      return;
    } catch (e) {
      return;
    }
  }
}
