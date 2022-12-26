import 'package:flutter/material.dart';

class SystemWaitEvent extends StatelessWidget {
  final String taskText;

  const SystemWaitEvent({
    super.key,
    required this.taskText,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        taskText,
        style: TextStyle(
          color: Theme.of(context).textTheme.headline6?.color,
        ),
      ),
    );
  }
}
