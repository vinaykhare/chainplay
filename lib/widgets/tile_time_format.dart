import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TileTimeView extends StatelessWidget {
  final DateTime at;
  final String tileTimeHeading;
  final TextStyle? textStyleForTime;
  final TextStyle? textStyleForDate;

  const TileTimeView({
    super.key,
    required this.at,
    required this.tileTimeHeading,
    required this.textStyleForTime,
    required this.textStyleForDate,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                tileTimeHeading,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                DateFormat.yMd().format(at),
                style: textStyleForDate,
              ),
            ],
          ),
        ),
        Text(
          "at ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}",
          style: textStyleForTime,
        ),
      ],
    );
  }
}
