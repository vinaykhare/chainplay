import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
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
            key: KeyHelper.homeCatKey,
            leading: Image.asset(assetMap["logoImage"]!),
            title: const Text(
              "C A T",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "CHAIN THE ACTIVITIES \nWITH TIMERS",
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
              FilePickerResult? result = await FilePicker.platform.pickFiles();

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
