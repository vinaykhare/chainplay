import 'dart:io';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';

class ChainActivityFlowCommonView extends StatelessWidget {
  const ChainActivityFlowCommonView({
    super.key,
    required this.activities,
    required this.arrowWidget,
    required this.chainActivity,
    required this.chainList,
    required this.tempChain,
    required this.editActivity,
    required this.undoEdit,
    required this.lineWidget,
    required this.index,
  });

  final List<ChainActivity> activities;
  final Widget arrowWidget;
  final ChainActivity chainActivity;
  final ChainList chainList;
  final Chain tempChain;
  final Function? editActivity;
  final Function? undoEdit;
  final Widget lineWidget;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).cardColor.withOpacity(0.1),
      onTap: () async {
        if (!chainActivity.edit) {
          editActivity!(chainActivity);
        } else {
          undoEdit!(chainActivity);
        }
      },
      title: Row(
        children: [
          Expanded(
            child: Text(
              chainActivity.activity.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: 100,
                margin: const EdgeInsets.all(5),
                child: chainActivity.activity.specification != null &&
                        chainActivity.activity
                                .specification![activitySpecImagePath] !=
                            null &&
                        chainActivity.activity
                                .specification![activitySpecImagePath] !=
                            ""
                    ? chainActivity
                            .activity.specification![activitySpecImagePath]
                            .toString()
                            .startsWith("http")
                        ? FadeInImage.assetNetwork(
                            placeholder: assetMap["logoImage"]!,
                            image: chainActivity
                                .activity.specification![activitySpecImagePath],
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              assetMap['logoImage']!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.file(
                            File(
                              chainActivity.activity
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
      subtitle: Text(
        "${chainActivity.endedAt != null ? 'Completed' : 'will Complete'} ${activities[index].isInterrupted ? ' before scheduled duration' : HelperFunctions.durationToString(chainActivity.activityDurationLeft ?? chainActivity.activityDuration)}.",
      ),
      leading: (chainActivity.endedAt != null || editActivity == null)
          ? Image.asset(assetMap['logoImage']!)
          : ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),

      // leading: Checkbox(
      //   key: ValueKey(
      //       'activities_checkbox_${chainActivity.activity.title}'),
      //   value: chainActivity.endedAt != null,
      //   onChanged: (value) async {
      //     await chainList.flipDoneActivity(
      //         tempChain, chainActivity);
      //   },
      // ),
    );
  }
}
