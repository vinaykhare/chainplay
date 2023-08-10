import 'dart:convert';
import 'dart:io';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
        IconButton(
          onPressed: () {
            Navigator.of(context)
                .pushReplacementNamed(AddChainScreen.routename);
          },
          icon: const Icon(
            Icons.add_box_outlined,
            size: 30,
          ),
        ),
        IconButton(
          onPressed: () async {
            NavigatorState nav = Navigator.of(context);
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if (result != null) {
              File uploadedFile = File(result.files.single.path!);
              String fileString = await uploadedFile.readAsString();
              Map<String, dynamic> jsonData = jsonDecode(fileString);
              Chain chain = Chain.fromJson(jsonData);
              nav.pushNamed(ViewChain.routename, arguments: {
                "chain": chain,
                "savedInDb": false,
              });
            } else {
              // User canceled the picker
            }
          },
          icon: const Icon(
            Icons.upload_outlined,
            size: 30,
          ),
        ),
      ],
    );
  }
}
