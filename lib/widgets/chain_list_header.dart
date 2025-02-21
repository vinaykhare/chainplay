import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            leading: InkWell(
              child: Image.asset(assetMap["logoImage"]!),
              onTap: () {
                ChainList chainList =
                    Provider.of<ChainList>(context, listen: false);
                chainList.loaded = false;
                chainList.initialize();
              },
            ),
            title: Text(
              "Chain & Play",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(
              "CHAIN THE ACTIVITIES \nAND PLAY IT",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        Semantics(
          label: "Create New Chain",
          child: IconButton(
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
      ],
    );
  }
}
