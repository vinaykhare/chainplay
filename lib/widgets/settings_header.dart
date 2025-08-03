import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height -
        // (appBarWidget.preferredSize.height * 1) -
        MediaQuery.of(context).viewPadding.top;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            leading: InkWell(
              child: Image.asset(
                assetMap["logoImage"]!,
                height: appHeight * 0.10,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(ChainListScreen.routename);
              },
            ),
            title: Text(
              "ChainPlay",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(
              "CHAIN THE ACTIVITIES & PLAY IT",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        Semantics(
          label: "App Drawer",
          child: IconButton(
            icon: const Icon(Icons.menu, size: 30.0),
            onPressed: () {
              // Open the drawer using the ScaffoldState.
              KeyHelper.scaffoldSettingsKey.currentState?.openEndDrawer();
            },
          ),
        )
      ],
    );
  }
}
