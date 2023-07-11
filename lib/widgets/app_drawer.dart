import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/screens/how_it_works.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                "CHAIN THE \nALARMS & TIMERS",
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
                leading: const Icon(Icons.help),
                title: Text(
                  'What is CAT?',
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
              const Divider(),
              ListTile(
                leading: const Icon(Icons.web_stories),
                title: Text(
                  'Add Sample Chains',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Text("made of Timer & Manual Tasks"),
                onTap: () async {
                  NavigatorState nav = Navigator.of(context);
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  await Provider.of<ChainList>(context, listen: false)
                      .loadSampleChains();
                  nav.pushReplacementNamed(ChainListScreen.routename);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.create_outlined,
                  size: 30,
                ),
                title: Text(
                  'Create Your Own Chain',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Text("of Timer & Manual Tasks"),
                onTap: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(AddChainScreen.routename);
                },
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
