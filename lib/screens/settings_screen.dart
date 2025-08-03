import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/widgets/db_settings.dart';
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
  late Map<String, int> activitiesCount;
  List<SystemSetting> settings = [];

  // Future<void> clearUnusedActivities() async {
  //   {
  //     //NavigatorState nav = Navigator.of(context);
  //     ScaffoldMessengerState scms = ScaffoldMessenger.of(context);

  //     bool? dialogResponse = await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text("Confirm Deletion"),
  //           content: const Text(
  //               "Are you sure about clearing all unused activities?"),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               child: Text(
  //                 "Yes!",
  //                 style: TextStyle(
  //                   color: Theme.of(context).colorScheme.error,
  //                 ),
  //               ),
  //             ),
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: Text(
  //                 "No, chose this option by mistake.",
  //                 style: TextStyle(
  //                   color: Theme.of(context).colorScheme.inverseSurface,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     );

  //     if (dialogResponse == true) {
  //       bool removed = await chainList.removeAllUnusedActivities(chainList
  //           .activities
  //           .where((activity) => activity.type == waitActivityInDB)
  //           .toList());

  //       scms.showSnackBar(
  //         SnackBar(
  //           // backgroundColor: theme.primaryColor,
  //           content: Text(
  //             //e.toString(),
  //             removed
  //                 ? "All Unused User Created Activities are deleted"
  //                 : "Failed to delete the Unused User created activities",
  //             // style: theme.textTheme.titleMedium,
  //             textAlign: TextAlign.center,
  //           ),
  //           duration: const Duration(seconds: 10),
  //           action: SnackBarAction(
  //             //textColor: Colors.white,
  //             label: 'OK',
  //             onPressed: () {},
  //           ),
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: true);
    chainList.fetchSettings().then((value) {
      setState(() {
        settings = value;
      });
    });
    activitiesCount = chainList.getCountForActivities();
  }

  @override
  Widget build(BuildContext context) {
    settings = chainList.systemSettings;
    return Semantics(
      label: "App Settings Screen",
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
          drawer: const AppDrawer(),
          body: SafeArea(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const ResetApp(),
                //const ShowBannerAd(),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      assetMap["logoImage"]!,
                      //fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //   child: Text(
                //     "Manage Activities",
                //     style: Theme.of(context).textTheme.titleMedium,
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: Column(
                //     children: [
                //       // Row(
                //       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       //   children: [
                //       //     const Text("Explore all User Activites"),
                //       //     ElevatedButton(
                //       //         onPressed: () {
                //       //           Navigator.of(context).push(
                //       //             MaterialPageRoute(
                //       //               //fullscreenDialog: true,
                //       //               builder: (context) {
                //       //                 return const ActivityListScreen();
                //       //               },
                //       //             ),
                //       //           );
                //       //         },
                //       //         child: const Icon(Icons.arrow_forward)),
                //       //   ],
                //       // ),
                //       Divider(
                //         color: Theme.of(context).primaryColor,
                //       ),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(activitiesCount[notInUse]! > 0
                //               ? "Clear ${activitiesCount[notInUse]} User Created Activities\nthat are not in use"
                //               : "All User Created activites\nare in use."),
                //           if (activitiesCount[notInUse]! > 0)
                //             ElevatedButton(
                //               onPressed: clearUnusedActivities,
                //               child: const Icon(Icons.clear_all),
                //             )
                //           else
                //             const ElevatedButton(
                //               onPressed: null,
                //               child: Icon(Icons.done),
                //             ),
                //         ],
                //       ),
                //       Divider(
                //         color: Theme.of(context).primaryColor,
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "System Settings",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: DbSettings(),
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

class ResetApp extends StatelessWidget {
  const ResetApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: TextButton.icon(
        label: Text(
          "Reset App to Factory Settings!",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  "Are you sure?",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      NavigatorState nav = Navigator.of(context);
                      await Provider.of<ChainList>(context, listen: false)
                          .clearDataBase();
                      nav.pop();
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
        icon: Icon(
          Icons.clear,
          color: Theme.of(context).shadowColor,
        ),
      ),
    );
  }
}
