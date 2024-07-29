import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/tutorial/screens/how_it_works.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
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
    return Semantics(
      label: "App Settings Screen",
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          if (chainList.getSettingByKey(showHelpOnNextBootKey).value ==
              trueSettingValue) {
            await Navigator.of(context)
                .pushReplacementNamed(HowItWorks.routename);
          }
        },
        child: Scaffold(
          drawer: const AppDrawer(),
          body: SafeArea(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.end,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Container(
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).cardColor,
                //   ),
                //   child: TextButton.icon(
                //     label: Text(
                //       "Reset App to Factory Settings!",
                //       style: Theme.of(context).textTheme.titleMedium,
                //     ),
                //     onPressed: () async {
                //       await showDialog(
                //         context: context,
                //         builder: (context) {
                //           return AlertDialog(
                //             content: Text(
                //               "Are you sure?",
                //               style: Theme.of(context).textTheme.titleLarge,
                //             ),
                //             actions: [
                //               IconButton(
                //                 onPressed: () => Navigator.of(context).pop(),
                //                 icon: const Icon(
                //                   Icons.close,
                //                 ),
                //               ),
                //               IconButton(
                //                 onPressed: () async {
                //                   NavigatorState nav = Navigator.of(context);
                //                   await Provider.of<ChainList>(context,
                //                           listen: false)
                //                       .clearDataBase();
                //                   nav.pop();
                //                 },
                //                 icon: const Icon(
                //                   Icons.check,
                //                 ),
                //               ),
                //             ],
                //           );
                //         },
                //       );
                //     },
                //     icon: Icon(
                //       Icons.clear,
                //       color: Theme.of(context).shadowColor,
                //     ),
                //   ),
                // ),

                //const ShowBannerAd(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: ListView.builder(
                      //reverse: true,
                      itemCount: settings.length,
                      itemBuilder: (context, index) {
                        List<String> listOfValues = [];
                        String dropdownValue = "";
                        if (settings[index].type == settingDataTypeList) {
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
                                if (!settings[index].type.startsWith("HIDDEN"))
                                  Expanded(child: Text(settings[index].key)),
                                if (settings[index].type == settingDataTypeBool)
                                  Switch(
                                    value: settings[index].value ==
                                        trueSettingValue,
                                    onChanged: (value) async {
                                      await chainList.setSetting(
                                        settings[index].key,
                                        value == true
                                            ? trueSettingValue
                                            : falseSettingValue,
                                      );
                                    },
                                  )
                                else if (settings[index].type ==
                                    settingDataTypeList)
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
                                  )
                                else
                                  Container(), //Invalid Use Case
                              ],
                            ),
                            if (!settings[index].type.startsWith("HIDDEN"))
                              Divider(
                                color: Theme.of(context).primaryColor,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const ShowBannerAd(),
                AppBar(
                  centerTitle: true,
                  title: const Text("Settings"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
