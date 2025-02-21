import 'package:chain_activities/widgets/chain_activity_flow_common_view.dart';
import 'package:chain_activities/widgets/chain_activity_flow_edit_view.dart';
import 'package:chain_activities/widgets/chain_activity_flow_read_view.dart';
import 'package:flutter/material.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';

class ChainActivityFlowView extends StatelessWidget {
  const ChainActivityFlowView({
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
    return Column(
      children: [
        arrowWidget,
        Card(
            elevation: 10,
            color: chainActivity.endedAt != null
                ? Theme.of(context).textSelectionTheme.selectionColor
                : chainActivity.edit
                    ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                    : Theme.of(context).cardColor,
            child: Column(
              children: [
                ChainActivityFlowCommonView(
                  key: Key("${index.toString()}_common"),
                  activities: activities,
                  arrowWidget: arrowWidget,
                  chainActivity: chainActivity,
                  chainList: chainList,
                  tempChain: tempChain,
                  editActivity: editActivity,
                  undoEdit: undoEdit,
                  lineWidget: lineWidget,
                  index: index,
                ),
                if (editActivity != null)
                  ChainActivityFlowEditView(
                    key: Key("${index.toString()}_edit"),
                    activities: activities,
                    arrowWidget: arrowWidget,
                    chainActivity: chainActivity,
                    chainList: chainList,
                    tempChain: tempChain,
                    editActivity: editActivity,
                    undoEdit: undoEdit,
                    lineWidget: lineWidget,
                    index: index,
                  )
                else
                  ChainActivityFlowReadView(
                    key: Key("${index.toString()}_read"),
                    activities: activities,
                    arrowWidget: arrowWidget,
                    chainActivity: chainActivity,
                    chainList: chainList,
                    tempChain: tempChain,
                    editActivity: editActivity,
                    undoEdit: undoEdit,
                    lineWidget: lineWidget,
                    index: index,
                  ),
              ],
            )),
      ],
    );
  }
}
