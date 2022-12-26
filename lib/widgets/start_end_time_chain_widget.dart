import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StartEndTimeChainWidget extends StatelessWidget {
  //final ChainEvent chainEvent;
  final String? cardTitle;
  final DateTime? startTime, endTime;
  final String? textInBetween;
  const StartEndTimeChainWidget({
    super.key,
    this.cardTitle,
    this.startTime,
    this.endTime,
    this.textInBetween,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cardTitle != null)
          Text(
            cardTitle!,
            style: Theme.of(context).textTheme.headline5,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 50,
              child: startTime != null
                  ? Text(
                      DateFormat.yMEd().add_jms().format(startTime!),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
            const Expanded(
                child: Divider(
              thickness: 5,
            )),
            if (textInBetween != null)
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).disabledColor,
                child: Text(
                  textInBetween!,
                  textAlign: TextAlign.center,
                ),
              ),
            if (textInBetween != null)
              const Expanded(
                child: Divider(
                  thickness: 5,
                ),
              ),
            CircleAvatar(
              radius: 50,
              child: endTime != null
                  ? Text(
                      DateFormat.yMEd().add_jms().format(endTime!),
                      textAlign: TextAlign.center,
                    )
                  : const Icon(Icons.workspace_premium_outlined),
            ),
          ],
        ),
      ],
    );
  }
}
