import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/search_schedule_screen.dart';
import 'package:schedule_it/widgets/app_drawer.dart';
//import 'package:schedule_it/widgets/app_drawer.dart';
import 'package:schedule_it/widgets/schedule_view.dart';

class ScheduleListScreen extends StatelessWidget {
  static String routename = "/schedules";

  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScheduleList scheduleList =
        Provider.of<ScheduleList>(context, listen: true);

    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text("Schedules"),
      //   backgroundColor: Colors.transparent,
      //   shadowColor: Theme.of(context).primaryColor,
      // ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: FutureBuilder(
          future: scheduleList.fetchSchedules(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final schedules = snapshot.data as List<Schedule>;
              // final pinnedSchedules =
              //     schedules.where((schedule) => schedule.pinned == true).toList();
              //final otherSchedules = schedules.where((schedule) => schedule.pinned != true).toList();
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ReorderableListView.builder(
                      reverse: true,
                      onReorder: (oldIndex, newIndex) =>
                          scheduleList.rearrangeSchedules(oldIndex, newIndex),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        Schedule schedule = schedules[index];
                        BannerAd? adSchedule = schedule.adBanner;
                        return ScheduleView(
                          adSchedule: adSchedule,
                          schedule: schedule,
                          key: Key(index.toString()),
                        );
                      },
                    ),
                  ),
                  AppBar(
                    centerTitle: true,
                    //automaticallyImplyLeading: false,
                    title: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.none,
                            cursorColor: Theme.of(context).cardColor,
                            showCursor: false,
                            onTap: () => Navigator.of(context)
                                .pushNamed(SearchScheduleScreen.routename),
                            decoration: const InputDecoration(
                              label: Text("Search Schedules"),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.black,
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
                            Icons.library_add,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }
          },
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
