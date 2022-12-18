import 'package:flutter/material.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
//import 'package:schedule_it/widgets/app_drawer.dart';
import 'package:schedule_it/widgets/schedule_view.dart';

class SearchScheduleScreen extends StatefulWidget {
  static String routename = "/search_schedules";

  const SearchScheduleScreen({super.key});

  @override
  State<SearchScheduleScreen> createState() => _SearchScheduleScreenState();
}

class _SearchScheduleScreenState extends State<SearchScheduleScreen> {
  List<Schedule> displaySchedules = [];
  late ScheduleList scheduleList;

  bool showFavorites = false, showRunning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scheduleList = Provider.of<ScheduleList>(context, listen: true);
    displaySchedules = scheduleList.schedules;
    showFavorites = false;
    showRunning = false;
  }

  runPredefinedFilter() {
    if (showFavorites || showRunning) {
      setState(
        () {
          displaySchedules = scheduleList.schedules
              .where(
                (element) =>
                    (showFavorites && element.pinned == true) ||
                    (showRunning && element.at != null),
              )
              .toList();
        },
      );
    } else {
      setState(() {
        displaySchedules = scheduleList.schedules;
      });
    }
  }

  runFilter(filter) {
    setState(() {
      showFavorites = false;
      showRunning = false;
    });
    if (filter == '') {
      setState(() {
        displaySchedules = scheduleList.schedules;
      });
    } else {
      setState(() {
        displaySchedules = scheduleList.schedules
            .where((element) => element.name
                .toLowerCase()
                .contains(filter.toString().toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: displaySchedules.length,
                itemBuilder: (context, index) {
                  Schedule schedule = displaySchedules[index];
                  //BannerAd? adSchedule = schedule.adBanner;
                  return ScheduleView(
                    //adSchedule: adSchedule,
                    schedule: schedule,
                    key: Key(index.toString()),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).cardColor,
                            Theme.of(context).primaryColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.favorite,
                          color: showFavorites
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).disabledColor,
                        ),
                        label: const Text("Favorites"),
                        onPressed: () {
                          showFavorites = !showFavorites;
                          runPredefinedFilter();
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).cardColor,
                            Theme.of(context).primaryColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.run_circle,
                          color: showRunning
                              ? Theme.of(context).secondaryHeaderColor
                              : Theme.of(context).disabledColor,
                        ),
                        label: const Text("Running"),
                        onPressed: () {
                          showRunning = !showRunning;
                          runPredefinedFilter();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppBar(
              title: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                cursorColor: Theme.of(context).iconTheme.color,
                onChanged: (value) {
                  runFilter(value);
                },
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  label: const Text("Search Schedules"),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).primaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
