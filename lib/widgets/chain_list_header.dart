import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChainListHeader extends StatelessWidget {
  const ChainListHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height -
        // (appBarWidget.preferredSize.height * 1) -
        MediaQuery.of(context).viewPadding.top;
    return Row(
      key: KeyHelper.homeChainAndPlayKey,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            leading: InkWell(
              child: Image.asset(
                key: KeyHelper.chainAndPlayTitle,
                assetMap["logoImage"]!,
                height: appHeight * 0.10,
              ),
              onTap: () {
                ChainList chainList =
                    Provider.of<ChainList>(context, listen: false);
                chainList.refresh();
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
          label: "Create New Chain",
          child: IconButton(
            key: KeyHelper.createNewChainButtonKey,
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(AddChainScreen.routename);
            },
            icon: const Icon(
              Icons.add_box_outlined,
              size: 30,
            ),
          ),
        ),
        Semantics(
          label: "Upload a chain in json format.",
          child: IconButton(
            key: KeyHelper.uploadChainButtonKey,
            onPressed: () async {
              NavigatorState nav = Navigator.of(context);
              ChainList chainList =
                  Provider.of<ChainList>(context, listen: false);
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ["json"],
              );

              if (result != null) {
                Chain? chain =
                    await chainList.uploadChain(result.files.single.path!);
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
            icon: const Icon(
              Icons.upload_outlined,
              size: 30,
            ),
          ),
        ),
        Semantics(
          label: "Search Chains",
          child: IconButton(
            key: KeyHelper.chainListSearchkey,
            icon: const Icon(Icons.search, size: 30.0),
            onPressed: () {
              // Open the drawer using the ScaffoldState.
              Navigator.of(context).pushNamed(SearchChainScreen.routename);
            },
          ),
        ),
        Semantics(
          label: "App Drawer",
          child: IconButton(
            key: KeyHelper.chainListAppDrwaerkey,
            icon: const Icon(Icons.menu, size: 30.0),
            onPressed: () {
              // Open the drawer using the ScaffoldState.
              KeyHelper.scaffoldChainListKey.currentState?.openEndDrawer();
            },
          ),
        )
      ],
    );
  }
}
