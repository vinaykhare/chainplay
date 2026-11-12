import 'dart:convert';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/db_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Exercises the onCreate / onUpgrade contract documented in lib/helpers/
// db_schema.dart without a device: sqflite_common_ffi runs SQLite in-process.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> openAt(int version) {
    return databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: version,
        onCreate: (db, v) async {
          for (String script in sqlInitScript) {
            await db.execute(script);
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          for (String statement in getMigrationSteps(oldVersion, newVersion)) {
            await db.execute(statement);
          }
          await repairActivitySpecifications(db);
        },
      ),
    );
  }

  test('fresh install creates the current schema and default settings',
      () async {
    Database db = await openAt(sqfLiteDBVersion);

    List<Map<String, Object?>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
    );
    List<String> names = tables.map((t) => t['name'] as String).toList();
    expect(
      names,
      containsAll(<String>[
        'activity',
        'chain',
        'chain_activity',
        'chain_activity_execution',
        'chain_execution',
        'settings',
      ]),
    );

    Map<String, Object?> darkTheme = (await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [darkThemeSettingKey],
    ))
        .single;
    expect(darkTheme['value'], falseSettingValue);

    await db.close();
  });

  test('no migration steps are registered below the current version', () {
    expect(
      dbMigrations.where((m) => m.version <= sqfLiteDBVersion),
      isNotEmpty,
      reason: "migrations registered at or below the current version apply",
    );
    expect(
      dbMigrations.where((m) => m.version > sqfLiteDBVersion),
      isEmpty,
      reason: "bump sqfLiteDBVersion when adding a DbMigration",
    );
  });

  test('v2 adds the sample chains opt-in next to the fresh-install default',
      () async {
    Database db = await openAt(sqfLiteDBVersion);

    Map<String, Object?> setting = (await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [addSampleChainsOnBootSettingKey],
    ))
        .single;
    expect(setting['value'], trueSettingValue);
    expect(setting['type'], settingDataTypeBool);

    await db.close();
  });

  test('an existing v1 database gains the opt-in on upgrade', () async {
    Database db = await openAt(sqfLiteDBVersion);
    await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [addSampleChainsOnBootSettingKey],
    );
    await db.setVersion(1);
    await db.close();

    db = await openAt(sqfLiteDBVersion);
    Map<String, Object?> setting = (await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [addSampleChainsOnBootSettingKey],
    ))
        .single;
    expect(setting['value'], trueSettingValue);
    await db.close();
  });

  test('getMigrationSteps selects only steps in (oldVersion, newVersion]', () {
    // Simulated registry, independent of the real one.
    const steps = [2, 3, 4];
    List<int> selected(int from, int to) =>
        steps.where((v) => v > from && v <= to).toList();

    expect(selected(1, 4), [2, 3, 4]);
    expect(selected(2, 4), [3, 4]);
    expect(selected(4, 4), isEmpty);
  });

  test('specification repair rewrites legacy string values', () async {
    Database db = await openAt(sqfLiteDBVersion);
    await db.insert('activity', {
      'activityId': 'legacy-url',
      'title': 'Legacy',
      'type': waitActivityInDB,
      'createdAt': 0,
      'lastUpdatedAt': 0,
      'edit': 0,
      'specifications': jsonEncode("https://example.com/a.gif"),
    });
    await db.insert('activity', {
      'activityId': 'legacy-local',
      'title': 'Legacy local',
      'type': waitActivityInDB,
      'createdAt': 0,
      'lastUpdatedAt': 0,
      'edit': 0,
      'specifications': '"/data/user/0/a.png"',
    });
    await db.insert('activity', {
      'activityId': 'already-good',
      'title': 'Good',
      'type': waitActivityInDB,
      'createdAt': 0,
      'lastUpdatedAt': 0,
      'edit': 0,
      'specifications': jsonEncode({activitySpecImagePath: "http://x/y.gif"}),
    });

    expect(await repairActivitySpecifications(db), 2);

    List<Map<String, Object?>> rows = await db.query('activity',
        where: 'activityId IN (?, ?, ?)',
        whereArgs: ['legacy-url', 'legacy-local', 'already-good'],
        orderBy: 'activityId');
    for (Map<String, Object?> row in rows) {
      expect(jsonDecode(row['specifications'] as String), isA<Map>());
    }
    Map<String, Object?> legacyUrl =
        rows.firstWhere((r) => r['activityId'] == 'legacy-url');
    expect(
      jsonDecode(legacyUrl['specifications'] as String)[activitySpecImagePath],
      "https://example.com/a.gif",
    );

    await db.close();
  });
}
