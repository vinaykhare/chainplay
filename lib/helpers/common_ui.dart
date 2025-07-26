import 'dart:io';

import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
}
