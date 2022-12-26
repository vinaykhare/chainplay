import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/helpers/key_helper.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/search_schedule_screen.dart';
import 'package:schedule_it/widgets/app_drawer.dart';
//import 'package:schedule_it/widgets/app_drawer.dart';
import 'package:schedule_it/widgets/schedule_list_item.dart';

class ScheduleListScreen extends StatelessWidget {
  static String routename = "/schedules";

  const ScheduleListScreen({super.key});

  // late ScheduleList scheduleList;
  // List<Schedule> schedules = [];

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   scheduleList = Provider.of<ScheduleList>(context, listen: true);
  //   // scheduleList.fetchSchedules().then((value) {
  //   //   setState(() {
  //   //     schedules = value;
  //   //   });
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: true);
    List<Schedule> schedules = scheduleList.schedules;

    return Scaffold(
      drawer: const AppDrawer(),
      key: KeyHelper.navigatorKey,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ReorderableListView.builder(
                reverse: true,
                onReorder: (oldIndex, newIndex) =>
                    Provider.of<ScheduleList>(context, listen: false)
                        .rearrangeSchedules(oldIndex, newIndex),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  Schedule schedule = schedules[index];
                  //BannerAd? adSchedule = schedule.adBanner;
                  return ScheduleListItem(
                    //adSchedule: adSchedule,
                    schedule: schedule,
                    showHistory: true,
                    allowFlag: true,
                    key: Key(
                      index.toString(),
                    ),
                    index: index,
                  );
                },
              ),
            ),
            AppBar(
              centerTitle: true,
              //automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.none,
                      cursorColor: Theme.of(context).cardColor,
                      showCursor: false,
                      onTap: () => Navigator.of(context)
                          .pushNamed(SearchScheduleScreen.routename),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        label: const Text("Search Schedules"),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(AddScheduleScreen.routename);
                    },
                    icon: const Icon(
                      Icons.watch_later,
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).pushNamed(AddScheduleScreen.routename);
      //   },
      //   child: const Icon(
      //     Icons.add,
      //   ),
      // ),
    );
  }
}
