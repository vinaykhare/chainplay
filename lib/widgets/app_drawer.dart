import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/screens/how_it_works.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AppBar(
            title: ListTile(
              onTap: () {
                // while (Navigator.of(context).canPop()) {
                //   Navigator.of(context).pop();
                // }
                Navigator.of(context)
                    .pushReplacementNamed(ChainListScreen.routename);
              },
              leading: Image.asset(assetMap["logoImage"]!),
              title: const Text(
                "C A T",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                "CHAIN OF \nALARMS & TIMERS",
              ),
            ),
            automaticallyImplyLeading: false,
            // actions: [
            //   IconButton(
            //     onPressed: () {
            //       while (Navigator.of(context).canPop()) {
            //         Navigator.of(context).pop();
            //       }
            //       Navigator.of(context)
            //           .pushReplacementNamed(SettingsScreen.routename);
            //     },
            //     icon: const Icon(Icons.settings),
            //   ),
            // ],
          ),
          Column(
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(SettingsScreen.routename);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text(
                  'How "CAT" Works',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(HowItWorks.routename);
                },
              ),
              const Divider(
                height: 30,
              ),
              ListTile(
                leading: const Icon(
                  Icons.post_add,
                  size: 30,
                ),
                title: Text(
                  'Create Your Own Chain',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Text("with Alarms OR Timers"),
                onTap: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(AddChainScreen.routename);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.home,
                  size: 35,
                ),
                title: Text(
                  'All Chains',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: const Text('of Alarms & Timers'),
                onTap: () {
                  // while (Navigator.of(context).canPop()) {
                  //   Navigator.of(context).pop();
                  // }
                  Navigator.of(context)
                      .pushReplacementNamed(ChainListScreen.routename);
                },
              ),
              const Divider(),
            ],
          )
        ],
      ),
    );
  }
}
