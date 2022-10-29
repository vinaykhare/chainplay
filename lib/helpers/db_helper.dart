import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'places.db'),
        onCreate: (db, version) async {
      return await db.execute(
          'CREATE TABLE activity(activityId TEXT PRIMARY KEY, title TEXT, activityDuration INTEGER, nextActivityAfter INTEGER, scheduleName TEXT)');
    }, version: 2);
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
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> removeData(
      String table, String condition, List<dynamic> conditionArgs) async {
    final db = await DBHelper.database();
    db.delete(table, where: condition, whereArgs: conditionArgs);
  }
}
