import 'package:chain_activities/helpers/constants.dart';
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
        if (chainActivity.edit)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: InkWell(
              onTap: () async {
                await undoEdit!(chainActivity);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.undo,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Text("Discard"),
                  ),
                ],
              ),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Semantics(
                  label: "Edit the chain activity title",
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await editActivity!(chainActivity, false, false);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: const Text("Title"),
                          ),
                          Icon(
                            Icons.edit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Semantics(
                  label: "Add or update Image for Chain Activity",
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await editActivity!(chainActivity, false, true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              chainActivity.activity.specification != null &&
                                      chainActivity.activity.specification![
                                              activitySpecImagePath] !=
                                          null &&
                                      chainActivity.activity.specification![
                                              activitySpecImagePath] !=
                                          ""
                                  ? "Edit"
                                  : "Add",
                            ),
                          ),
                          Icon(
                            chainActivity.activity.specification != null &&
                                    chainActivity.activity.specification![
                                            activitySpecImagePath] !=
                                        null &&
                                    chainActivity.activity.specification![
                                            activitySpecImagePath] !=
                                        ""
                                ? Icons.photo_camera
                                : Icons.add_a_photo,
                          ),
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
                        await editActivity!(chainActivity, true, false);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              chainActivity.activityDuration.inSeconds > 0
                                  ? "Edit"
                                  : "Add",
                            ),
                          ),
                          Icon(
                            chainActivity.activityDuration.inSeconds > 0
                                ? Icons.access_time_sharp
                                : Icons.more_time,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Semantics(
                label: "Delete this activity from chain.",
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                    ),
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
