import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

const initScript = [
  '''CREATE TABLE event (
      eventId TEXT PRIMARY KEY, 
      title TEXT, 
      specifications TEXT, 
      type INTEGER,
      createdAt INTEGER, 
      lastUpdatedAt INTEGER,
      edit INTEGER
    )
  ''',
  '''CREATE TABLE chain (
      title TEXT PRIMARY KEY,
      chainIndex INTEGER,
      createdAt INTEGER, 
      lastUpdatedAt INTEGER, 
      pinned INTEGER,
      startedAt INTEGER,
      endedAt INTEGER,
      chainStatus INTEGER,
      notificationId TEXT,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      editChain INTEGER
    )
  ''',
  '''CREATE TABLE chain_execution (
      chainExecutionId TEXT PRIMARY KEY,
      title TEXT,
      startedAt INTEGER,
      endedAt INTEGER,
      chainStatus INTEGER,
      notificationId TEXT,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title)
    )
  ''',
  '''CREATE TABLE chain_event (
      title TEXT, 
      eventId TEXT,
      eventIndex INTEGER,
      eventDone INTEGER,
      isInterrupted INTEGER,
      notificationId TEXT,
      eventDuration INTEGER,
      startedAt INTEGER,
      eventDurationLeft INTEGER,
      endedAt INTEGER,
      editChainEvent INTEGER,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title),
      FOREIGN KEY (eventId)
        REFERENCES event (eventId)
    )
  ''',
  '''CREATE TABLE chain_event_execution (
      chainExecutionId TEXT,
      title TEXT, 
      eventId TEXT,
      eventIndex INTEGER,
      eventDone INTEGER,
      isInterrupted INTEGER,
      notificationId TEXT,
      eventDuration INTEGER,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      startedAt INTEGER,      
      eventDurationLeft INTEGER,
      endedAt INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title),
      FOREIGN KEY (eventId)
        REFERENCES event (eventId),
      FOREIGN KEY (chainExecutionId)
        REFERENCES chain_execution (chainExecutionId)
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
    if (await sql.databaseExists(path.join(dbPath, 'testchainit.db'))) {
      sql.deleteDatabase(path.join(dbPath, 'testchainit.db'));
    }
    return sql.openDatabase(path.join(dbPath, 'chainit.db'),
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
