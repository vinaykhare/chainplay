import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/screens/how_it_works.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/models/system_setting.dart';
import 'package:chain_activities/widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  static String routename = "/settings";
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ChainList chainList;
  List<SystemSetting> settings = [];
  bool showNotificationPermissionWarning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: true);
    chainList.fetchSettings().then((value) {
      setState(() {
        settings = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    settings = chainList.systemSettings;
    return WillPopScope(
      onWillPop: () async {
        if (chainList.getSettingByKey(showHelpOnNextBootKey).value ==
            trueSettingValue) {
          await Navigator.of(context)
              .pushReplacementNamed(HowItWorks.routename);
        }
        return true;
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                              Provider.of<ChainList>(context, listen: false)
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
                        listOfValues =
                            settings[index].value.split(",").toList();
                        dropdownValue = listOfValues.first;
                      }

                      return Column(
                        children: [
                          Row(
                            key: ValueKey(settings[index].key),
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: Text(settings[index].key)),
                              if (settings[index].type == "BOOL")
                                Switch(
                                  value:
                                      settings[index].value == trueSettingValue,
                                  onChanged: (value) async {
                                    int setResponse =
                                        await chainList.setSetting(
                                      settings[index].key,
                                      value == true
                                          ? trueSettingValue
                                          : falseSettingValue,
                                    );
                                    if (setResponse ==
                                        setFailedDueToAppPermission) {
                                      setState(() {
                                        showNotificationPermissionWarning =
                                            true;
                                      });
                                    } else {
                                      setState(() {
                                        showNotificationPermissionWarning =
                                            false;
                                      });
                                    }
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
                                    await chainList.setSetting(
                                      settings[index].key,
                                      result.substring(0, result.length - 1),
                                    );
                                  },
                                  items: listOfValues
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                          const Divider(),
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
      ),
    );
  }
}
