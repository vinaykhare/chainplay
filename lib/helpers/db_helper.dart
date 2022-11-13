import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

const initScript = [
  '''CREATE TABLE activity (
      activityId TEXT PRIMARY KEY, 
      title TEXT, 
      activityDuration INTEGER, 
      nextActivityAfter INTEGER
    )
  ''',
  '''CREATE TABLE schedule (
      scheduleName TEXT PRIMARY KEY,
      scheduleIndex INTEGER,
      startedAt INTEGER,
      lastUpdatedAt INTEGER, 
      pinned INTEGER
    )
  ''',
  '''CREATE TABLE schedule_activity (
      scheduleName TEXT, 
      activityId TEXT,
      activityIndex INTEGER,
      activityDone INTEGER, 
      FOREIGN KEY (scheduleName)
        REFERENCES schedule (scheduleName),
      FOREIGN KEY (activityId)
        REFERENCES activity (activityId)
    )
  ''',
];

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'scheduleit.db'),
        onCreate: (db, version) async {
      for (var script in initScript) {
        await db.execute(script);
      }
    }, version: 1);
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

  static Future<List<Map<String, dynamic>>> getData(
      String table, String orderBy) async {
    final db = await DBHelper.database();
    return db.query(
      table,
      orderBy: orderBy, //"pinned DESC, lastUpdatedAt DESC",
    );
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
