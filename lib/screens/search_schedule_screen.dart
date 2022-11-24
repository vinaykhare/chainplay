import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:schedule_it/models/schedule.dart';
import 'package:schedule_it/models/schedule_list.dart';
import 'package:schedule_it/screens/add_schedule_screen.dart';
import 'package:schedule_it/widgets/app_drawer.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scheduleList = Provider.of<ScheduleList>(context, listen: true);
    displaySchedules = scheduleList.schedules;
  }

  runFilter(filter) {
    if (filter == '') {
      setState(() {
        displaySchedules = scheduleList.schedules;
      });
    } else {
      setState(() {
        displaySchedules = displaySchedules
            .where((element) => element.name
                .toLowerCase()
                .contains(filter.toString().toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    scheduleList = Provider.of<ScheduleList>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Schedules"),
      ),
      drawer: const AppDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: displaySchedules.length,
              itemBuilder: (context, index) {
                Schedule schedule = displaySchedules[index];
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
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    cursorColor: Theme.of(context).cardColor,
                    onChanged: (value) {
                      runFilter(value);
                    },
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
      ),
    );
  }
}
