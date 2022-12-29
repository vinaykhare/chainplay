import 'package:flutter/material.dart';

class SystemWaitActivityWithDuration extends StatelessWidget {
  final String taskText;

  const SystemWaitActivityWithDuration({
    super.key,
    required this.taskText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        //border: Border.all(width: 1),
        color: Theme.of(context).primaryColor,
      ),
      child: Text(
        taskText,
        textAlign: TextAlign.center,
      ),
    );
  }
}
