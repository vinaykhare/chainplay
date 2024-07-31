import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/widgets/list_of_activities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain_list.dart';

class ActivityListScreen extends StatefulWidget {
  static String routename = "/search_chains";

  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  List<Activity> displayActivities = [];
  late ChainList chainList;
  bool showWithImage = false,
      showWithoutImage = false,
      showInUse = false,
      showNotInUse = false;
  String? textFilter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    displayActivities = chainList.getActivitiesByFilters(textFilter ?? '',
        showWithImage, showWithoutImage, showInUse, showNotInUse);

    return Semantics(
      label: "Search Activities Screen",
      child: Scaffold(
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            //margin: const EdgeInsets.fromLTRB(8, 5, 8, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Text(
                    "Activites",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: null,
                  icon: const Icon(
                    Icons.swipe_right_sharp,
                  ),
                  label: Text(
                    "Swipe Right to delete an Activity",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  child: ListOfActivities(
                    textFilter: textFilter,
                    showAd: false,
                    showActivitiesInReverse: true,
                  ),
                ),
                AppBar(
                  title: TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    keyboardType: TextInputType.text,
                    cursorColor: Theme.of(context).iconTheme.color,
                    onChanged: (value) {
                      setState(() {
                        textFilter = value;
                      });
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      label: const Text("Search Activities"),
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
        ),
      ),
    );
  }
}
