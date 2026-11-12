import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/settings_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ChainList chainList = Provider.of<ChainList>(context, listen: false);
    return SafeArea(
      //top: false,
      child: Drawer(
        child: Builder(builder: (ctx) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListTile(
                onTap: () async {
                  // while (Navigator.of(context).canPop()) {
                  //   Navigator.of(context).pop();
                  // }
                  ModalRoute? modalRoute = ModalRoute.of(ctx);
                  if (modalRoute != null &&
                      (modalRoute.settings.name == ChainListScreen.routename ||
                          modalRoute.settings.name == "/")) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context)
                        .pushReplacementNamed(ChainListScreen.routename);
                  }
                },
                leading: Image.asset(assetMap["logoImage"]!),
                title: Text(
                  "ChainPlay",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  "CHAIN THE ACTIVITIES\n& PLAY IT",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),

              Column(
                children: [
                  const Divider(),
                  //const Divider(),
                  // Sample chains are offered once, on the first boot screen
                  // ("Add Sample Chains at Start"), so they are not repeated
                  // here.
                  ListTile(
                    leading: const Icon(
                      Icons.create,
                      size: 30,
                    ),
                    title: Text(
                      'Create Your Own Chain',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      "of Timer & Manual Tasks",
                      style: Theme.of(context).textTheme.labelSmall,
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
                    leading: const Icon(
                      Icons.upload,
                      size: 30,
                    ),
                    title: Text(
                      'Upload a Chain',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      "shared or downloaded from ChainPlay",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    onTap: () async {
                      NavigatorState nav = Navigator.of(context);
                      ChainList chainList =
                          Provider.of<ChainList>(context, listen: false);
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ["json"],
                      );

                      if (result != null) {
                        Chain? chain = await chainList
                            .uploadChain(result.files.single.path!);
                        nav.pushNamed(
                          ViewChain.routename,
                          arguments: {
                            "chain": chain ?? Chain(),
                            "savedInDb": false,
                            "invalidChain": chain == null,
                          },
                        );
                      } else {
                        // User canceled the picker
                      }
                    },
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Divider(),
                    const ShowBannerAd(),
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
              //const Divider(),
            ],
          );
        }),
      ),
    );
  }
}
