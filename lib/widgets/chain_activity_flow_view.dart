import 'dart:io';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/widgets/card_help_text.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/helpers/helper_functions.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/start_end_time_chain_widget.dart';

class ChainActivityFlowView extends StatelessWidget {
  const ChainActivityFlowView({
    Key? key,
    required this.activities,
    required this.arrowWidget,
    required this.chainActivity,
    required this.chainList,
    required this.tempChain,
    required this.editActivity,
    required this.undoEdit,
    required this.lineWidget,
    required this.index,
  }) : super(key: key);

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
    return Column(
      children: [
        arrowWidget,
        Card(
          elevation: 10,
          color: chainActivity.endedAt != null
              ? Theme.of(context).textSelectionTheme.selectionColor
              : chainActivity.edit
                  ? Theme.of(context).cardColor.withOpacity(0.5)
                  : Theme.of(context).cardColor,
          child: Dismissible(
            direction: editActivity != null
                ? DismissDirection.startToEnd
                : DismissDirection.none,
            background: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            key: ValueKey(
                'activities_dimissible_${chainActivity.activity.activityId}'),
            onDismissed: (_) async {
              await chainList.removeActivityFromChain(tempChain, chainActivity);
            },
            child: editActivity != null
                ? Column(
                    children: [
                      const CardHelpText(
                        title: "Tap this Card to edit",
                      ),
                      ListTile(
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
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  height: 100,
                                  margin: const EdgeInsets.all(5),
                                  child: chainActivity
                                                  .activity.specification !=
                                              null &&
                                          chainActivity.activity.specification![
                                                  activitySpecImagePath] !=
                                              null &&
                                          chainActivity.activity.specification![
                                                  activitySpecImagePath] !=
                                              ""
                                      ? chainActivity
                                              .activity
                                              .specification![
                                                  activitySpecImagePath]
                                              .toString()
                                              .startsWith("http")
                                          ? FadeInImage.assetNetwork(
                                              placeholder:
                                                  assetMap["logoImage"]!,
                                              image: chainActivity
                                                      .activity.specification![
                                                  activitySpecImagePath],
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(
                                                chainActivity.activity
                                                        .specification![
                                                    activitySpecImagePath],
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
                          "${chainActivity.endedAt != null ? 'Completed' : 'will Complete'} ${activities[index].isInterrupted ? ' before scheduled duration' : HelperFunctions.durationToString(chainActivity.activityDuration)}.",
                        ),
                        trailing: (chainActivity.endedAt != null ||
                                editActivity == null)
                            ? null
                            : ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle),
                              ),
                        leading: Checkbox(
                          key: ValueKey(
                              'activities_checkbox_${chainActivity.activity.title}'),
                          value: chainActivity.endedAt != null,
                          onChanged: (value) async {
                            await chainList.flipDoneActivity(
                                tempChain, chainActivity);
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                chainActivity.activity.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  height: 100,
                                  margin: const EdgeInsets.all(5),
                                  child: chainActivity
                                                  .activity.specification !=
                                              null &&
                                          chainActivity.activity.specification![
                                                  activitySpecImagePath] !=
                                              null &&
                                          chainActivity.activity.specification![
                                                  activitySpecImagePath] !=
                                              ""
                                      ? chainActivity
                                              .activity
                                              .specification![
                                                  activitySpecImagePath]
                                              .toString()
                                              .startsWith("http")
                                          ? FadeInImage.assetNetwork(
                                              placeholder:
                                                  assetMap["logoImage"]!,
                                              image: chainActivity
                                                      .activity.specification![
                                                  activitySpecImagePath],
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(
                                                chainActivity.activity
                                                        .specification![
                                                    activitySpecImagePath],
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
                          "${chainActivity.endedAt != null ? 'Completed' : 'will Complete'} ${activities[index].isInterrupted ? ' before scheduled duration' : HelperFunctions.durationToString(chainActivity.activityDuration)}.",
                        ),
                        leading: Checkbox(
                          key: ValueKey(
                              'activities_checkbox_${chainActivity.activity.title}'),
                          value: chainActivity.endedAt != null,
                          onChanged: (value) async {
                            await chainList.flipDoneActivity(
                                tempChain, chainActivity);
                          },
                        ),
                      ),
                      if (chainActivity.at != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StartEndTimeChainWidget(
                            cardTitle: null,
                            startTime: chainActivity.at,
                            endTime: chainActivity.endedAt,
                            textInBetween: chainActivity.activityDurationLeft !=
                                        null &&
                                    chainActivity.endedAt == null &&
                                    chainActivity.activityDuration.inSeconds > 0
                                ? "Paused"
                                : null,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
