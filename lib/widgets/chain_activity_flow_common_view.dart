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
    String subtitleText = "";
    if (chainActivity.endActivityNotificationId != noValueInDB &&
        chainActivity.endedAt != null) {
      if (chainActivity.endedAt != null &&
          chainActivity.endedAt!
                  .difference(
                    DateTime.now(),
                  )
                  .inSeconds >
              0) {
        subtitleText +=
            "You will be notified for activity completion\n${HelperFunctions.durationToString(
          chainActivity.endedAt!.difference(
            DateTime.now(),
          ),
        )}\nfrom now.";
      } else {
        subtitleText +=
            "Acitivity completed. Notification should have been received by now. Please refresh.";
      }
    } else {
      if (chainActivity.endedAt != null) {
        subtitleText += "has completed ";
      } else {
        subtitleText += "will complete ";
      }

      if (activities[index].isInterrupted) {
        subtitleText += "before the scheduled duration";
      } else {
        subtitleText += HelperFunctions.durationToString(
            chainActivity.activityDurationLeft ??
                chainActivity.activityDuration);
      }

      if (chainActivity.activityDurationLeft != null) {
        subtitleText += " after resuming";
      }
    }

    return ListTile(
      tileColor: Theme.of(context).cardColor.withValues(alpha: 0.1),
      // onTap: () async {
      //   if (!chainActivity.edit && editActivity != null) {
      //     editActivity!(chainActivity);
      //   } else {
      //     undoEdit!(chainActivity);
      //   }
      // },
      title: Text(
        chainActivity.activity.title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      subtitle: Text(
        subtitleText,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 100,
          margin: const EdgeInsets.all(5),
          child: chainActivity.activity.specification != null &&
                  chainActivity
                          .activity.specification![activitySpecImagePath] !=
                      null &&
                  chainActivity
                          .activity.specification![activitySpecImagePath] !=
                      ""
              ? chainActivity.activity.specification![activitySpecImagePath]
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
                        chainActivity
                            .activity.specification![activitySpecImagePath],
                      ),
                      fit: BoxFit.cover,
                    )
              : Image.asset(
                  assetMap['logoImage']!,
                  fit: BoxFit.cover,
                ),
        ),
      ),

      trailing: !chainActivity.edit && editActivity != null
          ? ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            )
          : null,

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
