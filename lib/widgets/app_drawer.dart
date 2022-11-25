import 'package:flutter/material.dart';
import 'package:schedule_it/screens/acitivity_list_screen.dart';
import 'package:schedule_it/screens/schedule_list_screen.dart';

//import '../screens/search_schedule_screen.dart';
//import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AppBar(
            title: const Text('Schedule It'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          Column(
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.task_alt_sharp),
                title: const Text('Activities'),
                onTap: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(ActivityListScreen.routename);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.watch_later,
                ),
                title: Text(
                  'Schedules',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  while (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  Navigator.of(context)
                      .pushReplacementNamed(ScheduleListScreen.routename);
                },
              ),
              const Divider(),
            ],
          )
        ],
      ),
    );
  }
}
