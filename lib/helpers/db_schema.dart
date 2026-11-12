// Database schema definition and version upgrades.
//
// HOW THIS WORKS
//  - `sqfLiteDBVersion` is the schema version the code expects. It is passed to
//    sqflite's `openDatabase(version: ...)`.
//  - Fresh installs run `sqlInitScript` (full, current schema) via `onCreate`.
//  - Installs that already have an older database run `dbMigrations` via
//    `onUpgrade`: only the steps with a version greater than the version on
//    the device are executed, in ascending order.
//
// WHEN YOU NEED A MIGRATION
//  Any change to an existing table (add/rename/drop/alter a column, change a
//  constraint, add an index) or any data backfill. Adding a brand-new table
//  only for users of the new version also needs a migration step, because
//  existing devices never run `onCreate` again.
//
// HOW TO ADD ONE
//  1. Bump `sqfLiteDBVersion` by one.
//  2. Append a step to `dbMigrations` with the same version number, using
//     only additive, backwards-compatible SQL (typically
//     `ALTER TABLE x ADD COLUMN y`). Never edit `sqlInitScript` history:
//     instead make the `CREATE TABLE` in `sqlInitScript` match the resulting
//     schema so fresh installs and migrated installs converge.
//  3. Add or update a test in `test/db_migration_test.dart` (runs on the
//     sqflite_common_ffi in-memory database, no device needed).
//
// Rules of thumb:
//  - sqflite wraps `onUpgrade` in a transaction; a throw rolls it back and the
//    open fails, so keep steps deterministic and idempotent where possible.
//  - `ALTER TABLE ... ADD COLUMN` cannot add NOT NULL columns without a
//    default; prefer nullable columns or a default value.
//  - Do not drop columns that old code still reads; the app never downgrades.

import 'dart:convert';

import 'package:chain_activities/helpers/constants.dart';
import 'package:sqflite/sqflite.dart';

const int sqfLiteDBVersion = 2;

const sqlInitScript = [
  '''CREATE TABLE activity (
      activityId TEXT PRIMARY KEY, 
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
      pivotDate INTEGER,
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
      pivotDate INTEGER,
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
  '''CREATE TABLE chain_activity (
      title TEXT, 
      activityId TEXT,
      activityIndex INTEGER,
      activityDone INTEGER,
      isInterrupted INTEGER,
      notificationId TEXT,
      activityDuration INTEGER,
      startedAt INTEGER,
      activityDurationLeft INTEGER,
      endedAt INTEGER,
      editChainActivity INTEGER,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title),
      FOREIGN KEY (activityId)
        REFERENCES activity (activityId)
    )
  ''',
  '''CREATE TABLE chain_activity_execution (
      chainExecutionId TEXT,
      title TEXT, 
      activityId TEXT,
      activityIndex INTEGER,
      activityDone INTEGER,
      isInterrupted INTEGER,
      notificationId TEXT,
      activityDuration INTEGER,
      repeatType TEXT,
      repeatTypeGap INTEGER,
      repeatCount INTEGER,
      startedAt INTEGER,      
      activityDurationLeft INTEGER,
      endedAt INTEGER,
      FOREIGN KEY (title)
        REFERENCES chain (title),
      FOREIGN KEY (activityId)
        REFERENCES activity (activityId),
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
      '$darkThemeSettingKey',
      '$falseSettingValue',
      '$settingDataTypeBool'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      '$appSoundSettingKey',
      '$trueSettingValue',
      '$settingDataTypeBool'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      '$showHelpOnNextBootKey', 
      '$trueSettingValue',
      '$settingDataTypeHiddenBool'
    )
  ''',
  '''INSERT INTO settings(key, value, type) VALUES (
      '$addSampleChainsOnBootSettingKey', 
      '$trueSettingValue',
      '$settingDataTypeHiddenBool'
    )
  ''',
];

// One entry per schema version that existing databases must be moved to.
// Version 1 is the initial schema, created by `sqlInitScript`, so there is no
// migration for it.
const List<DbMigration> dbMigrations = [
  DbMigration(
    version: 2,
    description: "Let the user opt out of the sample chains on first boot",
    steps: [
      '''INSERT OR IGNORE INTO settings(key, value, type) VALUES (
      '$addSampleChainsOnBootSettingKey',
      '$trueSettingValue',
      '$settingDataTypeBool'
    )''',
    ],
  ),
  // Example of a future step (do not uncomment without bumping the version):
  //
  // DbMigration(
  //   version: 2,
  //   description: "Track when an activity was last played",
  //   steps: [
  //     "ALTER TABLE activity ADD COLUMN lastPlayedAt INTEGER",
  //   ],
  // ),
];

class DbMigration {
  final int version;
  final String description;

  /// SQL statements executed in order inside sqflite's upgrade transaction.
  final List<String> steps;

  const DbMigration({
    required this.version,
    required this.description,
    required this.steps,
  });
}

/// Statements to run when a database at [oldVersion] is opened by code that
/// expects [newVersion].
List<String> getMigrationSteps(int oldVersion, int newVersion) {
  List<String> steps = [];
  for (DbMigration migration in dbMigrations) {
    if (migration.version > oldVersion && migration.version <= newVersion) {
      steps.addAll(migration.steps);
    }
  }
  return steps;
}

/// Normalises an `activity.specifications` JSON string.
///
/// Older builds stored the image URL as a bare string instead of the expected
/// object (for example `"https://..."` instead of `{"imagePath": "..."}`),
/// which crashes `fetchActivities()` on load. Rewrites such rows in place.
Future<int> repairActivitySpecifications(Database db) async {
  List<Map<String, Object?>> rows = await db.query(
    'activity',
    columns: ['activityId', 'specifications'],
  );
  int repaired = 0;
  for (Map<String, Object?> row in rows) {
    Object? raw = row['specifications'];
    if (raw is! String || raw.trim().isEmpty) {
      continue;
    }
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      decoded = null;
    }
    if (decoded is Map<String, dynamic>) {
      continue;
    }
    String imagePath = decoded is String ? decoded : "";
    await db.update(
      'activity',
      {
        'specifications': jsonEncode({activitySpecImagePath: imagePath})
      },
      where: 'activityId = ?',
      whereArgs: [row['activityId']],
    );
    repaired++;
  }
  return repaired;
}
