import 'dart:convert';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/system_configuration.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static Future<Database> sqfLiteDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    // if (await sql.databaseExists(path.join(dbPath, 'chainactivities.db'))) {
    //   sql.deleteDatabase(path.join(dbPath, 'chainactivities.db'));
    // }
    return sql.openDatabase(path.join(dbPath, 'chainactivities.db'),
        onCreate: (db, version) async {
      for (var script in sqlInitScript) {
        await db.execute(script);
      }
    }, version: sqfLiteDBVersion);
  }

  static Future<SharedPreferencesAsync> sharedPrefDatabase() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
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

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    if (kIsWeb) {
      insertInSharedPrefDatabase(table, data);
    } else {
      insertInSQFLiteDatabase(table, data);
    }
  }

  static Future<void> insertInSharedPrefDatabase(
      String table, Map<String, dynamic> data) async {
    final SharedPreferencesAsync asyncPrefs = await sharedPrefDatabase();
    List<String> tableContent = await asyncPrefs.getStringList(table) ?? [];
    tableContent.add(jsonEncode(data));
    asyncPrefs.setStringList(table, tableContent);
    return;
  }

  static Future<void> insertInSQFLiteDatabase(
      String table, Map<String, dynamic> data) async {
    final db = await DBHelper.sqfLiteDatabase();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(String table, Map<String, dynamic> data,
      String condition, List<dynamic> conditionArgs) async {
    if (kIsWeb) {
      updateInSharedPrefDatabase(table, data, condition, conditionArgs);
    } else {
      updateInSQFLite(table, data, condition, conditionArgs);
    }
  }

  static Future<void> updateInSQFLite(String table, Map<String, dynamic> data,
      String condition, List<dynamic> conditionArgs) async {
    final db = await DBHelper.sqfLiteDatabase();
    await db.update(
      table,
      data,
      where: condition,
      whereArgs: conditionArgs,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateInSharedPrefDatabase(
      String table,
      Map<String, dynamic> data,
      String condition,
      List<dynamic> conditionArgs) async {
    final SharedPreferencesAsync asyncPrefs = await sharedPrefDatabase();
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

  static Future<List<Map<String, dynamic>>> getData(
      String table, String orderBy,
      [String condition = "", List<dynamic> conditionArgs = const []]) async {
    List<Map<String, dynamic>> result = [];
    if (kIsWeb) {
      result =
          await getDataFromSharedPref(table, orderBy, condition, conditionArgs);
    } else {
      result =
          await getDataFromSQFLite(table, orderBy, condition, conditionArgs);
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getDataFromSQFLite(
      String table, String orderBy,
      [String condition = "", List<dynamic> conditionArgs = const []]) async {
    final db = await DBHelper.sqfLiteDatabase();

    if (condition == "") {
      return db.query(
        table,
        orderBy: orderBy, //"pinned DESC, lastUpdatedAt DESC",
      );
    } else {
      return db.query(
        table,
        orderBy: orderBy, //"pinned DESC, lastUpdatedAt DESC",
        where: condition,
        whereArgs: conditionArgs,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> getDataFromSharedPref(
      String table, String orderBy,
      [String condition = "", List<dynamic> conditionArgs = const []]) async {
    List<Map<String, dynamic>> result = [];
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
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

  static Future<List<Map<String, dynamic>>> getDataBySQL(
      String sql, List<dynamic> conditionArgs) async {
    final db = await DBHelper.sqfLiteDatabase();
    return db.rawQuery(sql, conditionArgs);
  }

  static Future<List<Map<String, dynamic>>> getJointResultFromSharedPref(
      List<String> tables,
      String joinBy,
      List<String> conditionParams,
      List<dynamic> conditionArgs,
      String orderBy) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

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

  static Future<List<Map<String, dynamic>>> getJointResult(
      List<String> tables,
      String joinBy,
      List<String> conditionParams,
      List<dynamic> conditionArgs,
      String orderBy) async {
    List<Map<String, dynamic>> result = [];

    if (kIsWeb) {
      result = await getJointResultFromSharedPref(
          tables, joinBy, conditionParams, conditionArgs, orderBy);
    } else {
      String selectStatement = "",
          fromTable = tables[0],
          joinStatement = "",
          whereStatement = "";

      for (int tableIndex = 0; tableIndex < tables.length; tableIndex++) {
        selectStatement = "$selectStatement${tables[tableIndex]}.*";
        if (tableIndex < tables.length - 1) {
          selectStatement = "$selectStatement, ";
        } else {
          selectStatement = "$selectStatement ";
        }
        if (tableIndex > 0 && tableIndex < tables.length) {
          if (joinStatement != "") {
            joinStatement = "$joinStatement ";
          }
          joinStatement =
              "${joinStatement}JOIN ${tables[tableIndex]} ON (${tables[tableIndex]}.$joinBy = ${tables[tableIndex - 1]}.$joinBy)";
        }
      }

      for (int i = 0; i < conditionParams.length; i++) {
        if (whereStatement != "") {
          whereStatement = "$whereStatement AND ";
        }
        whereStatement =
            "$whereStatement${tables[0]}.${conditionParams[i]} ='${conditionArgs[i]}'";
      }

      String sql = '''
      SELECT $selectStatement
      FROM $fromTable
      $joinStatement
      WHERE $whereStatement
      ORDER BY $fromTable.$orderBy
      ''';
      result = await getDataBySQL(
        sql,
        conditionArgs,
      );
    }

    return result;
  }

  static Future<void> removeData(
      String table, String condition, List<dynamic> conditionArgs) async {
    if (kIsWeb) {
      return removeDataFromSharedPref(table, condition, conditionArgs);
    } else {
      return removeDataFromSQFLite(table, condition, conditionArgs);
    }
  }

  static Future<void> removeDataFromSQFLite(
      String table, String condition, List<dynamic> conditionArgs) async {
    final db = await DBHelper.sqfLiteDatabase();
    if (condition != "") {
      db.delete(table, where: condition, whereArgs: conditionArgs);
    } else {
      db.delete(table);
    }
  }

  static Future<void> removeDataFromSharedPref(
      String table, String condition, List<dynamic> conditionArgs) async {
    try {
      final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
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
