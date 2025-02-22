import 'dart:io';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain_list.dart';

class ActivityListItem extends StatelessWidget {
  //final BannerAd? adChain;
  final Activity activity;
  final bool showHistory, allowFlag;
  final String? tutorialChain;

  final int index;

  const ActivityListItem({
    super.key,
    //this.adChain,
    required this.activity,
    required this.showHistory,
    required this.allowFlag,
    required this.index,
    this.tutorialChain,
  });

  Key getGlobaleKey(String tutorialChain, Key defaultKey) {
    switch (tutorialChain) {
      case sampleWorkoutChainTitle:
        return KeyHelper.sampleWorkoutChainViewKey;
      case sampleDietRoutineChainTitle:
        return KeyHelper.sampleDietChainViewKey;
      case sampleMedicineRoutineChainTitle:
        return KeyHelper.sampleMedicineChainViewKey;
      default:
        return defaultKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    ChainList chainList = Provider.of<ChainList>(context);
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    double appWidth = MediaQuery.of(context).size.width - 16;
    List<Chain> chiansUsingThisActivity =
        chainList.getChainsUsingThisActivity(activity);
    return Dismissible(
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
        ),
        child: const Icon(Icons.delete),
      ),
      key: ValueKey("activity_list_dismissible_${activity.title}"),
      onDismissed: (direction) async {
        await chainList.removeActivity(activity);
      },
      confirmDismiss: (DismissDirection direction) async {
        if (chiansUsingThisActivity.isEmpty) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Deletion"),
                content:
                    const Text("Are you sure about deleting this Activity?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      "Yes, Delete the Activity!",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "No, chose this option by mistake.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("${activity.title}\nis in use by"),
                  content: Text(
                    chiansUsingThisActivity.map((Chain chain) {
                      return chain.title;
                    }).toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Ok",
                      ),
                    ),
                  ],
                );
              });
        }
      },
      child: Card(
        elevation: 10,
        child: SizedBox(
          width: appWidth,
          height: appHeight * 0.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: appWidth * 0.6,
                padding: const EdgeInsets.all(
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      //softWrap: true,
                    ),
                    Text(chiansUsingThisActivity.isEmpty
                        ? "Not in use"
                        : "In Use"),
                  ],
                ),
              ),
              SizedBox(
                width: appWidth * 0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    //height: 100,
                    margin: const EdgeInsets.all(5),
                    child: activity.specification != null &&
                            activity.specification![activitySpecImagePath] !=
                                null &&
                            activity.specification![activitySpecImagePath] != ""
                        ? activity.specification![activitySpecImagePath]
                                .toString()
                                .startsWith("http")
                            ? FadeInImage.assetNetwork(
                                placeholder: assetMap["logoImage"]!,
                                image: activity
                                    .specification![activitySpecImagePath],
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) => Image.asset(
                                  assetMap['logoImage']!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.file(
                                File(
                                  activity
                                      .specification![activitySpecImagePath],
                                ),
                                fit: BoxFit.cover,
                              )
                        : Image.asset(
                            assetMap['logoImage']!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
