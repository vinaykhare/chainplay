import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/start_end_time_chain_widget.dart';

class ChainActivityFlowReadView extends StatelessWidget {
  const ChainActivityFlowReadView({
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
    return (chainActivity.at != null)
        ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.1),
            ),
            padding: const EdgeInsets.all(8.0),
            child: StartEndTimeChainWidget(
              cardTitle: null,
              startTime: chainActivity.at,
              endTime: chainActivity.endedAt,
              textInBetween: chainActivity.endedAt != null
                  ? chainActivity.activityDone == false
                      ? chainActivity.endActivityNotificationId == noValueInDB
                          ? "Running"
                          : "Scheduled"
                      : "Done"
                  : chainActivity.activityDurationLeft != null &&
                          chainActivity.activityDuration.inSeconds > 0
                      ? "Paused"
                      : null,
              // textInBetween: chainActivity.activityDurationLeft !=
              //             null &&
              //         chainActivity.endedAt == null &&
              //         chainActivity.activityDuration.inSeconds > 0
              //     ? "Paused"
              //     : chainActivity.endedAt == null
              //         ? "Running"
              //         : null,
            ),
          )
        : Container(); //Invalid Use Case
  }
}
