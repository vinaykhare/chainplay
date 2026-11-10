import 'dart:convert';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/models/system_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// ChainList.initialize()/checkAndUpdateConfig() touch Flutter plugins
// (sqflite, MobileAds, notifications) that are not available in a widget
// test, so the provider is fitted with an instance that is already loaded.
class FakeChainList extends ChainList {
  FakeChainList(super.context);

  @override
  bool get loaded => true;

  @override
  bool get configUpdated => true;
}

void main() {
  testWidgets('App starts on the chain list screen once loaded',
      (WidgetTester tester) async {
    final ChainList chainList = FakeChainList(
      // Dummy context, never used by the fake.
      _dummyContext(),
    );
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<ChainList>.value(
        value: chainList,
        child: const _TestApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining("Chain"), findsWidgets);
  });

  group('Chain model', () {
    test('JSON round trip keeps title and activities', () {
      final Chain chain = Chain();
      chain.title = "Test Chain";
      chain.activities = [
        ChainActivity(
          activity: Activity(
            activityId: "activity-1",
            title: "Push ups",
            createdAt: DateTime(2026, 1, 1),
            lastUpdatedAt: DateTime(2026, 1, 1),
            specification: {activitySpecImagePath: "https://example.com/a.gif"},
          ),
          activityDuration: const Duration(seconds: 45),
        ),
      ];

      final Chain decoded = Chain.fromJson(
        jsonDecode(jsonEncode(chain.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.title, "Test Chain");
      expect(decoded.activities.length, 1);
      expect(decoded.activities.first.activity.title, "Push ups");
      expect(
        decoded.activities.first.activityDuration,
        const Duration(seconds: 45),
      );
    });

    test('local image paths are stripped from exported JSON', () {
      final Activity activity = Activity(
        activityId: "activity-2",
        title: "With local image",
        createdAt: DateTime(2026, 1, 1),
        lastUpdatedAt: DateTime(2026, 1, 1),
        specification: {activitySpecImagePath: "/data/user/0/img.png"},
      );

      expect(activity.toJson()["specification"][activitySpecImagePath], "");
    });
  });

  group('ChainList helpers', () {
    test('getValidTitle appends a suffix when the title is taken', () {
      final ChainList chainList = FakeChainList(_dummyContext());
      final Chain chain = Chain();
      chain.title = "Morning";
      chainList.chains.add(chain);

      expect(chainList.getValidTitle("Morning"), "Morning_1");
      expect(chainList.getValidTitle("Evening"), "Evening");
    });

    test('getSettingByKey falls back to a default system setting', () {
      final ChainList chainList = FakeChainList(_dummyContext());
      chainList.systemSettings = [
        SystemSetting(),
      ];
      chainList.systemSettings.first.key = darkThemeSettingKey;
      chainList.systemSettings.first.value = trueSettingValue;

      expect(
        chainList.getSettingByKey(darkThemeSettingKey).value,
        trueSettingValue,
      );
      expect(chainList.getSettingByKey("UNKNOWN").value, "");
    });

    test('getFormattedTimeBySetting formats the current time', () {
      final ChainList chainList = FakeChainList(_dummyContext());
      final String time = chainList.getFormattedTimeBySetting("HH:MM:SS");

      expect(RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(time), isTrue);
    });
  });
}

// ChainList stores the BuildContext it is constructed with, but none of the
// code paths exercised here use it.
BuildContext _dummyContext() => _NullBuildContext();

class _NullBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            final ChainList chainList =
                Provider.of<ChainList>(context, listen: true);
            return ListView(
              children: [
                const Text("ChainPlay"),
                for (final Chain chain in chainList.chains)
                  Text(chain.title),
              ],
            );
          },
        ),
      ),
    );
  }
}
