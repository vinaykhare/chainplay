import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

const initScript = [
  '''CREATE TABLE activity (
      activityId TEXT PRIMARY KEY, 
      title TEXT, 
      type INTEGER,
      createdAt INTEGER, 
      lastUpdatedAt INTEGER,
      editActivity INTEGER
    )
  ''',
  '''CREATE TABLE schedule (
      scheduleName TEXT PRIMARY KEY,
      scheduleIndex INTEGER,
      createdAt INTEGER, 
      lastUpdatedAt INTEGER, 
      pinned INTEGER,
      startedAt INTEGER,
      endedAt INTEGER,
      scheduleStatus INTEGER,
      notificationId TEXT,
      editSchedule INTEGER
    )
  ''',
  '''CREATE TABLE schedule_activity (
      scheduleName TEXT, 
      activityId TEXT,
      activityIndex INTEGER,
      activityDone INTEGER,
      notificationId TEXT,
      activityDuration INTEGER,
      nextActivityAfter INTEGER,
      startedAt INTEGER,
      endedAt INTEGER,
      editScheduleActivity INTEGER,
      editNextActivity INTEGER,
      FOREIGN KEY (scheduleName)
        REFERENCES schedule (scheduleName),
      FOREIGN KEY (activityId)
        REFERENCES activity (activityId)
    )
  ''',
  '''CREATE TABLE settings (
      key TEXT PRIMARY KEY, 
      value TEXT,
      type TEXT
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      'DARK THEME', 
      'FALSE',
      'BOOL'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      'Notification Type',
      'App Notification,None',
      'LIST'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      'App Sound', 
      'TRUE',
      'BOOL'
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
