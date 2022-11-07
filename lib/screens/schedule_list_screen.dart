import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/screens/play_schedule_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  static String routename = "/schedules";

  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  late ScheduleList scheduleList;

  @override
  void dispose() {
    super.dispose();
    scheduleList.disposeAds();
  }

  @override
  Widget build(BuildContext context) {
    scheduleList = Provider.of<ScheduleList>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Schedules"),
      ),
      body: FutureBuilder(
        future: Provider.of<ScheduleList>(context, listen: false)
            .fetchAllSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final schedules = snapshot.data as List<Schedule>;
            return ReorderableListView.builder(
              itemCount: schedules.length,
              itemBuilder: ((context, index) {
                Schedule schedule = schedules[index];
                BannerAd? adSchedule = schedule.adBanner;
                return Container(
                  padding: const EdgeInsets.all(5.0),
                  key: ValueKey("schedule_list_container_${schedule.name}"),
                  child: Card(
                    elevation: 5,
                    child: adSchedule != null
                        ? SizedBox(
                            height: 50,
                            child: AdWidget(
                              ad: adSchedule,
                            ),
                          )
                        : Dismissible(
                            background: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                              ),
                            ),
                            key: ValueKey(
                                "schedule_list_dismissible_${schedule.name}"),
                            onDismissed: (direction) {
                              scheduleList.removeSchedule(schedule);
                            },
                            child: ListTile(
                              onTap: () => Navigator.of(context).pushNamed(
                                AddScheduleScreen.routename,
                                arguments: schedule,
                              ),
                              title: Text(schedule.name),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: IconButton(
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(
                                    PlaySchedule.routename,
                                    arguments: schedule,
                                  ),
                                  icon: const Icon(Icons.play_arrow),
                                ),
                              ),
                              trailing: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle),
                              ),
                            ),
                          ),
                  ),
                );
              }),
              onReorder: (int oldIndex, int newIndex) {
                scheduleList.rearrangeSchedules(oldIndex, newIndex);
              },
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
