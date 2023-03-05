import 'package:flutter/material.dart';

class SystemWaitActivity extends StatelessWidget {
  final String taskText;

  const SystemWaitActivity({
    super.key,
    required this.taskText,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          taskText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
    );
  }
}
