import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
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
          onPressed: () {},
          icon: const Icon(
            Icons.upload_outlined,
            size: 30,
          ),
        ),
      ],
    );
  }
}
