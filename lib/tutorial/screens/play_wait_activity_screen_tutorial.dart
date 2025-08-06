import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/widgets/show_banner_ad.dart';
import 'package:flutter/material.dart';

class PlayWaitActivityScreenTutorial extends StatelessWidget {
  static String routename = "run_activity_tutorial";
  const PlayWaitActivityScreenTutorial({super.key});

  //Build Function

  @override
  Widget build(BuildContext context) {
    double appWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Semantics(
        label: "Play Timer Tutorial Screen",
        child: Scaffold(
          body: SafeArea(
            child: OrientationBuilder(builder: (context, orientation) {
              Widget activityContent = SingleChildScrollView(
                child: Column(
                  key: KeyHelper.playWaitKey,
                  children: [
                    Text(
                      key: KeyHelper.playWaitTitleKey,
                      "Generic Activity",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "will compelte\nin 5 Hours, 4 Minutes\nand",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    CircleAvatar(
                      key: KeyHelper.playWaitTimerKey,
                      radius: 50,
                      backgroundColor: Theme.of(context).canvasColor,
                      child: FittedBox(
                        child: Text(
                          "30",
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Text(
                      "Seconds.",
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton.icon(
                      key: KeyHelper.playWaitGoBackAndNotifyKey,
                      label: const Text("Go Back & Notify when done"),
                      onPressed: () {},
                      icon: Icon(
                        Icons.notification_add,
                      ),
                    ),
                    if (orientation == Orientation.portrait)
                      Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).cardColor,
                        ),
                        child: const ShowBannerAd(),
                      ),
                  ],
                ),
              );
              Widget activityImage = Container(
                margin: const EdgeInsets.all(5),
                width: appWidth,
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        assetMap['logoImage']!,
                        // fit: BoxFit.fitHeight,
                        //height: appHeight * 0.45,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        key: KeyHelper.playWaitRotateScreenKey,
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                        ),
                        icon: Icon(
                          Icons.screen_rotation,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              );
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).canvasColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sample Screen to guide you",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.error),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: activityImage),
                  activityContent,
                ],
              );
            }),
          ),
          bottomNavigationBar: SafeArea(
            child: Row(
              children: [
                Row(
                  key: KeyHelper.playWaitBackwardKey,
                  children: [
                    Icon(
                      Icons.timeline,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 5,
                      ),
                      child: const Text("Chain Status"),
                    ),
                  ],
                ),
                Expanded(
                  child: IconButton(
                    key: KeyHelper.playWaitPlayPauseKey,
                    onPressed: () {},
                    icon: Icon(Icons.pause),
                  ),
                ),
                Row(
                  key: KeyHelper.playWaitForwardKey,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        right: 5,
                      ),
                      child: Text(
                        "Next Activity",
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
