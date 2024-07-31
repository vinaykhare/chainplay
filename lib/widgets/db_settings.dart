import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/models/system_setting.dart';
import 'package:flutter/material.dart';

class DbSettings extends StatelessWidget {
  const DbSettings({
    super.key,
    required this.settings,
    required this.chainList,
  });

  final List<SystemSetting> settings;
  final ChainList chainList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          //reverse: true,
          itemCount: settings.length,
          itemBuilder: (context, index) {
            List<String> listOfValues = [];
            String dropdownValue = "";
            if (settings[index].type == settingDataTypeList) {
              listOfValues = settings[index].value.split(",").toList();
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
                        value: settings[index].value == trueSettingValue,
                        onChanged: (value) async {
                          await chainList.setSetting(
                            settings[index].key,
                            value == true
                                ? trueSettingValue
                                : falseSettingValue,
                          );
                        },
                      )
                    else if (settings[index].type == settingDataTypeList)
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
                            .map<DropdownMenuItem<String>>((String value) {
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
    );
  }
}
