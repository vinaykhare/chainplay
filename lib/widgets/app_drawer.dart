import 'package:flutter/material.dart';
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
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.branding_watermark),
            title: const Text('Activities'),
            onTap: () {},
          ),
          const Divider(),
        ],
      ),
    );
  }
}
