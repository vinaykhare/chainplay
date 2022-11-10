import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/widgets/app_drawer.dart';
import 'package:schedule_it/widgets/schedule_view.dart';
import 'package:schedule_it/widgets/search_bar.dart';

class ScheduleListScreen extends StatelessWidget {
  static String routename = "/schedules";

  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //ScheduleList scheduleList = Provider.of<ScheduleList>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const SearchBar(), //const Text("Schedules"),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<ScheduleList>(context).fetchAllSchedules(),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      Schedule schedule = schedules[index];
                      BannerAd? adSchedule = schedule.adBanner;
                      return ScheduleView(
                        adSchedule: adSchedule,
                        schedule: schedule,
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddScheduleScreen.routename);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
