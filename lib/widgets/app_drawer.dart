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
            title: const ListTile(
              title: Text(
                "C A T",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "CHAIN ACTIVITIES WITH TIMERS",
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
                  'Create Your Chain of Activities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  'with Timers.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(AddChainScreen.routename);
                },
              ),
              ListTile(
                leading: const Icon(Icons.watch_later),
                title: Text(
                  'Chains',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
