import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/schedule_history_screen.dart';
import 'package:schedule_it/widgets/app_drawer.dart';
//import 'package:schedule_it/widgets/app_drawer.dart';

class ScheduleListHistoryScreen extends StatelessWidget {
  static String routename = "/schedules_history";

  const ScheduleListHistoryScreen({super.key});

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
    List<Schedule> schedules =
        Provider.of<ScheduleList>(context, listen: true).schedules;
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                // onReorder: (oldIndex, newIndex) =>
                //     Provider.of<ScheduleList>(context, listen: false)
                //         .rearrangeSchedules(oldIndex, newIndex),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  Schedule schedule = schedules[index];
                  BannerAd? adSchedule = schedule.adBanner;
                  return Card(
                    elevation: 5,
                    child: adSchedule != null
                        ? SizedBox(
                            height: 50,
                            child: AdWidget(ad: adSchedule),
                          )
                        : ListTile(
                            title: Text(schedule.name),
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                  ScheduleHistoryScreen.routename,
                                  arguments: schedule,
                                );
                              },
                              icon: const Icon(Icons.forward),
                            ),
                          ),
                  );
                },
              ),
            ),
            AppBar(
              centerTitle: true,
              title: const Text("Executed Schedules"),
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
