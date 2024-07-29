import 'package:flutter/material.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_activity.dart';
import 'package:chain_activities/models/chain_list.dart';

class ChainActivityFlowEditView extends StatelessWidget {
  const ChainActivityFlowEditView({
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: "Delete this activity from chain.",
              child: IconButton(
                onPressed: () async {
                  bool? dialogResponse = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Deletion"),
                        content: const Text(
                            "Are you sure about deleting this Activity?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              "Yes, Delete this Activity!",
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (dialogResponse == true) {
                    await chainList.removeActivityFromChain(
                        tempChain, chainActivity);
                  }
                },
                icon: const Icon(
                  Icons.delete_forever_rounded,
                ),
              ),
            ),
            Semantics(
              label: "Edit or Undo Edit this Chain Activity",
              child: IconButton(
                icon: Icon(
                  chainActivity.edit ? Icons.undo : Icons.edit,
                ),
                onPressed: () async {
                  if (!chainActivity.edit) {
                    editActivity!(chainActivity);
                  } else {
                    undoEdit!(chainActivity);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
