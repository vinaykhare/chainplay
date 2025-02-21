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
            Expanded(
              child: Semantics(
                label: "Delete this activity from chain.",
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: InkWell(
                    onTap: () async {
                      bool? dialogResponse = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Deletion"),
                            content: const Text(
                                "Are you sure about deleting this Activity?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  "Yes, Delete this Activity!",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_forever_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const Text("Delete"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                label: "Edit or Undo Edit this Chain Activity",
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: InkWell(
                    onTap: () async {
                      if (!chainActivity.edit) {
                        editActivity!(chainActivity);
                      } else {
                        undoEdit!(chainActivity);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          chainActivity.edit ? Icons.undo : Icons.edit,
                        ),
                        const Text("Edit"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Semantics(
                label: "Button to reorder the Chain Items.",
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      const Text("Reorder"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
