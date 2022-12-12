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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              label: const Text("Reset App to Factory Settings!"),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text("Are you sure?"),
                      actions: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Provider.of<ScheduleList>(context, listen: false)
                                .clearDataBase();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.check,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.clear,
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: ListView.builder(
                  reverse: true,
                  itemCount: settings.length,
                  itemBuilder: (context, index) {
                    List<String> listOfValues = [];
                    String dropdownValue = "";
                    if (settings[index].type == "LIST") {
                      listOfValues = settings[index].value.split(",").toList();
                      dropdownValue = listOfValues.first;
                    }

                    return Row(
                      key: ValueKey(settings[index].key),
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text(settings[index].key)),
                        if (settings[index].type == "BOOL")
                          Switch(
                            value: settings[index].value == "TRUE",
                            onChanged: (value) async {
                              await scheduleList.setSetting(
                                settings[index].key,
                                value == true ? "TRUE" : "FALSE",
                              );
                            },
                          )
                        else if (settings[index].type == "LIST")
                          DropdownButton<String>(
                            value: dropdownValue,
                            onChanged: (String? value) async {
                              if (value == null || value == "") {
                                return;
                              }
                              listOfValues.remove(value);
                              listOfValues.insert(0, value);
                              String result = "";
                              for (String value in listOfValues) {
                                result += '$value,';
                              }
                              await scheduleList.setSetting(
                                settings[index].key,
                                result.substring(0, result.length - 1),
                              );
                            },
                            items: listOfValues
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
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
