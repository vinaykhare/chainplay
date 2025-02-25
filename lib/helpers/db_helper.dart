import 'dart:convert';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/system_configuration.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static Future<Database> database() async {
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

  static Future<List<Map<String, dynamic>>> getWebSettings() async {
    if (kIsWeb) {
      List<Map<String, dynamic>> defaultSetting = [
        {
          "key": darkThemeSettingKey,
          "value": falseSettingValue,
          "type": settingDataTypeBool,
        },
        {
          "key": appSoundSettingKey,
          "value": trueSettingValue,
          "type": settingDataTypeBool,
        },
        {
          "key": showHelpOnNextBootKey,
          "value": trueSettingValue,
          "type": settingDataTypeBool,
        },
      ];
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
      final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
      List<String>? tableContent;
      try {
        Map<String, Object?> allTables = await asyncPrefs.getAll();
        if (allTables["settings"] == null) {
          asyncPrefs.setStringList("settings", defaultEncodedSetting);
        } else {
          tableContent = await asyncPrefs.getStringList("settings");
        }
      } catch (e) {
        asyncPrefs.setStringList("settings", defaultEncodedSetting);
      }
      if (tableContent != null) {
        defaultSetting.clear();
        for (String setting in tableContent) {
          Map<String, dynamic> decodedSetting = jsonDecode(setting);
          defaultSetting.add(decodedSetting);
        }
      }
      return defaultSetting;
    }
    return [{}];
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    if (kIsWeb) {
      final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
      List<String>? tableContent = await asyncPrefs.getStringList(table);
      tableContent ??= [];
      tableContent.add(jsonEncode(data));
      asyncPrefs.setStringList(table, tableContent);
      return;
    }
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(String table, Map<String, Object> data,
      String condition, List<dynamic> conditionArgs) async {
    if (kIsWeb) {
      final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
      try {
        List<String>? tableContent = await asyncPrefs.getStringList(table);
        if (tableContent == null) {
          return;
        }
        asyncPrefs.remove(table);
        int rowToBeUpdated = tableContent.indexWhere((String entry) {
          Map<String, Object> objectEntry = jsonDecode(entry);
          return objectEntry[condition.split("=").first.trim()] ==
              conditionArgs[0];
        });

        if (rowToBeUpdated == -1) {
          return;
        }

        Map<String, Object> objectEntry =
            jsonDecode(tableContent[rowToBeUpdated]);

        tableContent.removeAt(rowToBeUpdated);
        // update objectEntry
        data.forEach((key, value) {
          objectEntry[key] = value;
        });
        tableContent.add(jsonEncode(objectEntry));

        asyncPrefs.setStringList(table, tableContent);

        return;
      } catch (e) {
        return;
      }
    }
    final db = await DBHelper.database();
    await db.update(
      table,
      data,
      where: condition,
      whereArgs: conditionArgs,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // if (x <= 0) {
    //   // ignore: avoid_print
    //   print(
    //       "No rows updated in Table: $table with condition: $condition and Condtion args: $conditionArgs");
    // }
  }

  static Future<List<Map<String, dynamic>>> getData(
      String table, String orderBy,
      [String condition = "", List<dynamic> conditionArgs = const []]) async {
    if (kIsWeb) {
      final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
      List<String>? tableContent = await asyncPrefs.getStringList(table);
      if (tableContent == null) {
        return [{}];
      }
      int requrestedRow = tableContent.indexWhere((String entry) {
        Map<String, Object> objectEntry = jsonDecode(entry);
        return objectEntry[condition.split("=").first.trim()] ==
            conditionArgs[0];
      });
      if (requrestedRow == -1) {
        return [{}];
      }
      return jsonDecode(tableContent[requrestedRow]);
    }

    final db = await DBHelper.database();

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

  static Future<List<Map<String, dynamic>>> getDataBySQL(
      String sql, List<dynamic> conditionArgs) async {
    final db = await DBHelper.database();
    return db.rawQuery(sql, conditionArgs);
  }

  static Future<void> removeData(
      String table, String condition, List<dynamic> conditionArgs) async {
    if (kIsWeb) {
      try {
        final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
        List<String>? tableContent = await asyncPrefs.getStringList(table);
        if (tableContent == null) {
          return;
        }
        asyncPrefs.remove(table);
        tableContent.removeWhere((String entry) {
          Map<String, Object> objectEntry = jsonDecode(entry);
          return objectEntry[condition.split("=").first.trim()] ==
              conditionArgs[0];
        });

        asyncPrefs.setStringList(table, tableContent);

        return;
      } catch (e) {
        return;
      }
    }
    final db = await DBHelper.database();
    if (condition != "") {
      db.delete(table, where: condition, whereArgs: conditionArgs);
    } else {
      db.delete(table);
    }
  }
}
