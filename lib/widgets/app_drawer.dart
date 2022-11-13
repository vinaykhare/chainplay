import 'package:flutter/material.dart';
import 'package:schedule_it/screens/acitivity_list_screen.dart';
import 'package:schedule_it/screens/schedule_list_screen.dart';
//import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text('Schedule It'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.branding_watermark),
            title: const Text('Schedules'),
            onTap: () {
              while (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pushNamed(ScheduleListScreen.routename);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.branding_watermark),
            title: const Text('Activities'),
            onTap: () {
              while (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pushNamed(ActivityListScreen.routename);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
