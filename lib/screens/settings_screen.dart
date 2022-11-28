import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/models/system_setting.dart';
import 'package:schedule_it/widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  static String routename = "/settings";
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ScheduleList scheduleList;
  List<SystemSetting> settings = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scheduleList = Provider.of<ScheduleList>(context, listen: true);
    scheduleList.fetchSettings().then((value) {
      setState(() {
        settings = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    settings = scheduleList.systemSettings;
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: settings.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text(settings[index].key)),
                        Switch(
                            value: settings[index].value == "TRUE",
                            onChanged: (value) async {
                              await scheduleList.setSetting(
                                settings[index].key,
                                value == true ? "TRUE" : "FALSE",
                              );
                            }),
                      ],
                    );
                  },
                ),
              ),
            ),
            AppBar(
              centerTitle: true,
              title: const Text("Settings"),
            )
          ],
        ),
      ),
    );
  }
}
