import 'package:chain_activities/models/activity.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/activity_list_item.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOfActivities extends StatefulWidget {
  final String? textFilter;
  final bool? showAd, showActivitiesInReverse;
  final bool showNotInUse;
  const ListOfActivities({
    super.key,
    this.textFilter,
    this.showAd,
    this.showActivitiesInReverse,
    required this.showNotInUse,
  });

  @override
  State<ListOfActivities> createState() => _ListOfActivitiesState();
}

class _ListOfActivitiesState extends State<ListOfActivities> {
  bool showChainControlSummary = true;
  List<Activity> displayActivities = [];
  late ChainList chainList;
  bool showWithImage = false,
      showWithoutImage = false,
      showInUse = false,
      showNotInUse = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chainList = Provider.of<ChainList>(context, listen: true);
  }

  @override
  Widget build(BuildContext context) {
    // ChainList chainList = Provider.of<ChainList>(context, listen: true);
    // List<Chain> chains = chainList.chains;
    showNotInUse = widget.showNotInUse;
    displayActivities = chainList.getActivitiesByFilters(
        widget.textFilter ?? '',
        showWithImage,
        showWithoutImage,
        showInUse,
        showNotInUse);

    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: displayActivities.length,
            reverse: widget.showActivitiesInReverse != null &&
                widget.showActivitiesInReverse == true,
            itemBuilder: (context, index) {
              Activity activity = displayActivities[index];
              //BannerAd? adChain = chain.adBanner;
              return ActivityListItem(
                //adChain: adChain,
                activity: activity,
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
        if (widget.showAd == null || widget.showAd == true)
          Container(
            margin: const EdgeInsets.all(5),
            //padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
            ),
            child: const ShowBannerAd(),
          ),
        // Container(
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).primaryColor,
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Expanded(
        //         child: Card(
        //           child: Container(
        //             decoration: BoxDecoration(
        //               gradient: LinearGradient(
        //                 colors: [
        //                   Theme.of(context).cardColor,
        //                   Theme.of(context).primaryColor,
        //                 ],
        //                 begin: Alignment.topCenter,
        //                 end: Alignment.bottomCenter,
        //               ),
        //             ),
        //             child: TextButton.icon(
        //               icon: Icon(
        //                 Icons.account_circle,
        //                 color: showWithImage
        //                     ? Theme.of(context).secondaryHeaderColor
        //                     : Theme.of(context).disabledColor,
        //               ),
        //               label: Text(
        //                 "With\nImage",
        //                 style: Theme.of(context).textTheme.labelLarge,
        //               ),
        //               onPressed: () async {
        //                 setState(() {
        //                   showWithImage = !showWithImage;
        //                 });
        //               },
        //             ),
        //           ),
        //         ),
        //       ),
        //       Expanded(
        //         child: Card(
        //           child: Container(
        //             decoration: BoxDecoration(
        //               gradient: LinearGradient(
        //                 colors: [
        //                   Theme.of(context).cardColor,
        //                   Theme.of(context).primaryColor,
        //                 ],
        //                 begin: Alignment.topCenter,
        //                 end: Alignment.bottomCenter,
        //               ),
        //             ),
        //             child: TextButton.icon(
        //               icon: Icon(
        //                 Icons.no_accounts,
        //                 color: showWithoutImage
        //                     ? Theme.of(context).secondaryHeaderColor
        //                     : Theme.of(context).disabledColor,
        //               ),
        //               label: Text(
        //                 "W/O\nImage",
        //                 style: Theme.of(context).textTheme.labelLarge,
        //               ),
        //               onPressed: () {
        //                 setState(() {
        //                   showWithoutImage = !showWithoutImage;
        //                 });
        //               },
        //             ),
        //           ),
        //         ),
        //       ),
        //       Expanded(
        //         child: Card(
        //           child: Container(
        //             decoration: BoxDecoration(
        //               gradient: LinearGradient(
        //                 colors: [
        //                   Theme.of(context).cardColor,
        //                   Theme.of(context).primaryColor,
        //                 ],
        //                 begin: Alignment.topCenter,
        //                 end: Alignment.bottomCenter,
        //               ),
        //             ),
        //             child: TextButton.icon(
        //               icon: Icon(
        //                 Icons.done_all,
        //                 color: showInUse
        //                     ? Theme.of(context).secondaryHeaderColor
        //                     : Theme.of(context).disabledColor,
        //               ),
        //               label: Text(
        //                 "In\nUse",
        //                 style: Theme.of(context).textTheme.labelLarge,
        //               ),
        //               onPressed: () {
        //                 setState(() {
        //                   showInUse = !showInUse;
        //                 });
        //               },
        //             ),
        //           ),
        //         ),
        //       ),
        //       Expanded(
        //         child: Card(
        //           child: Container(
        //             decoration: BoxDecoration(
        //               gradient: LinearGradient(
        //                 colors: [
        //                   Theme.of(context).cardColor,
        //                   Theme.of(context).primaryColor,
        //                 ],
        //                 begin: Alignment.topCenter,
        //                 end: Alignment.bottomCenter,
        //               ),
        //             ),
        //             child: TextButton.icon(
        //               icon: Icon(
        //                 Icons.remove_done,
        //                 color: showNotInUse
        //                     ? Theme.of(context).secondaryHeaderColor
        //                     : Theme.of(context).disabledColor,
        //               ),
        //               label: Text(
        //                 "Not\nIn Use",
        //                 style: Theme.of(context).textTheme.labelLarge,
        //               ),
        //               onPressed: () {
        //                 setState(() {
        //                   showNotInUse = !showNotInUse;
        //                 });
        //               },
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
