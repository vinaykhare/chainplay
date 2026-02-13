import 'dart:io';

import 'package:chain_activities/helpers/common_logic.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommonUI {
  Future<DateTime?> getDateTimeDialog(
    BuildContext context,
    DateTime? chainStartTime,
  ) async {
    return await showDialog<DateTime>(
        context: context,
        builder: (ctx) {
          final TextEditingController addStartDateController =
              TextEditingController();
          final TextEditingController addStartTimeController =
              TextEditingController();
          TimeOfDay selectedTime = TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 1)));

          DateTime chainStartDate = DateTime.now();
          addStartDateController.text =
              DateFormat.yMEd().format(chainStartDate);
          chainStartTime = DateTime(
            chainStartDate.year,
            chainStartDate.month,
            chainStartDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          addStartTimeController.text =
              DateFormat.jms().format(chainStartTime!);
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Schedule Chain"),
                IconButton(
                  icon: Icon(Icons.cancel,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select the date & time when you want to start this chain.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addStartDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Start Date",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          chainStartDate = await showDatePicker(
                                context: ctx,
                                initialDate: chainStartDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              ) ??
                              chainStartDate;
                          addStartDateController.text =
                              DateFormat.yMEd().format(chainStartDate);
                          chainStartTime = DateTime(
                            chainStartDate.year,
                            chainStartDate.month,
                            chainStartDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: addStartTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Start Time",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          selectedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              ) ??
                              selectedTime;
                          chainStartTime = DateTime(
                            chainStartDate.year,
                            chainStartDate.month,
                            chainStartDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          addStartTimeController.text =
                              DateFormat.jms().format(chainStartTime!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  chainStartDate = DateTime.now().subtract(Duration(days: 1));
                  chainStartTime = DateTime(
                    chainStartDate.year,
                    chainStartDate.month,
                    chainStartDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  Navigator.of(ctx).pop(chainStartTime);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(chainStartTime);
                },
                child: Text(
                  "Schedule",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<bool?> confirmScheduleCancelation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chain is running in background"),
          content: const Text(
              "Are you sure about force completing the current activity and go to the next one?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Yes, Do it!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "No, my bad!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> dialogCheckPlayTutorialAgain(
      BuildContext context, String tutorialType) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("LAUNCH THIS TUTORIAL AGAIN?"),
          content: Text(
              "To Launch this tutorial again, Enable \n$tutorialType\nunder the settings."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Ok",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getImageByPath(String imagePath) {
    return imagePath == ""
        ? Image.asset(
            assetMap['noImagePlaceholder']!,
            fit: BoxFit.fitHeight,
          )
        : imagePath.startsWith("http")
            ? FadeInImage.assetNetwork(
                placeholder: assetMap["noImagePlaceholder"]!,
                image: imagePath,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                  assetMap['noImagePlaceholder']!,
                  fit: BoxFit.cover,
                ),
              )
            : Image.file(
                File(imagePath),
                //fit: BoxFit.cover,
              );
  }

  Widget getIconForChain(Chain chain) {
    if (chain.notificationId == trueInDB) {
      return const Icon(Icons.stop_circle_outlined);
    }
    if (chain.chainStatus == statusExecuting) {
      return const Icon(Icons.pause_circle_outline_rounded);
    }
    return const Icon(Icons.play_arrow_outlined);
  }

  Row showChainActions(BuildContext context, Chain chain) {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Semantics(
          label: "Delete this chain.",
          child: InkWell(
            onTap: () async {
              NavigatorState nav = Navigator.of(context);
              bool? dialogResponse = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm Deletion"),
                    content:
                        const Text("Are you sure about deleting this Chain?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          "Yes, Delete the Chain!",
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

              if (dialogResponse == true) {
                await chainList.removeChain(chain);
                nav.pop();
              }
            },
            child: Icon(Icons.delete_forever_outlined),
          ),
        ),
        Semantics(
          label: "Download this chain.",
          child: InkWell(
            onTap: () async {
              ScaffoldMessengerState scm = ScaffoldMessenger.of(context);
              String downloadResponse =
                  await Provider.of<ChainList>(context, listen: false)
                      .checkAndDownloadChain(context, chain);

              scm.showSnackBar(SnackBar(
                content: Text(downloadResponse),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
              ));
            },
            child: Icon(Icons.download),
          ),
        ),
        Semantics(
          label: "Share this chain.",
          child: InkWell(
            onTap: () async {
              await Provider.of<ChainList>(context, listen: false)
                  .checkAndShareChain(context, chain);
            },
            child: Icon(Icons.share_outlined),
          ),
        ),
        Semantics(
          label: "Mark this chain as Favorite.",
          child: InkWell(
            onTap: () async {
              chain.pinned = !chain.pinned;
              await Provider.of<ChainList>(context, listen: false)
                  .updateChain(chain, false);
            },
            child: chain.pinned
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border_outlined),
          ),
        ),
        if (chain.notificationId != trueInDB)
          Semantics(
            label: "Schedule the Chain",
            child: InkWell(
              onTap: () => CommonLogic().scheduleTheChain(context, chain),
              // onTap: () async {
              //   NavigatorState nav = Navigator.of(context);
              //   bool allWell = await onPopOut(false);
              //   if (allWell) {
              //     nav.pushNamed(
              //       ScheduleChainScreen.routename,
              //       arguments: {
              //         "chain": chain,
              //       },
              //     );
              //   }
              // },
              child: Icon(Icons.alarm_outlined),
            ),
          ),
      ],
    );
  }
}
