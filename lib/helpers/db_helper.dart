import 'package:chain_activities/helpers/db_schema.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

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
    }, onUpgrade: (db, oldVersion, newVersion) async {
      await upgradeSchema(db, oldVersion, newVersion);
    }, version: sqfLiteDBVersion);
  }

  /// Runs every migration step registered between [oldVersion] and
  /// [newVersion], plus data repairs that must survive schema changes.
  /// sqflite already wraps this in a transaction, so a throwing step rolls the
  /// whole upgrade back and the next open retries it.
  static Future<void> upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (var statement in getMigrationSteps(oldVersion, newVersion)) {
      await db.execute(statement);
    }
    await repairActivitySpecifications(db);
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(String table, Map<String, Object> data,
      String condition, List<dynamic> conditionArgs) async {
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
    final db = await DBHelper.database();
    if (condition != "") {
      db.delete(table, where: condition, whereArgs: conditionArgs);
    } else {
      db.delete(table);
    }
  }
}
