import 'package:flutter/material.dart';

class RestTask extends StatelessWidget {
  final String taskText;

  const RestTask({
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
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
