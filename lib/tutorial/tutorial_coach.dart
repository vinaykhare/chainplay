import 'dart:ui';

import 'package:chain_activities/helpers/common_ui.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';

import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/tutorial/screens/play_wait_activity_screen_tutorial.dart';
import 'package:chain_activities/widgets/cat_text_button.dart';
import 'package:chain_activities/widgets/home_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:chain_activities/widgets/app_bottom_buttons_help.dart';
import 'package:chain_activities/widgets/app_header_buttons_help.dart';
import 'package:chain_activities/widgets/chain_tile_help.dart';

class TutorialCoach {
  final String tutorialType;
  final BuildContext context;

  TutorialCoach({
    required this.tutorialType,
    required this.context,
  });

  List<TargetFocus> targets = [];
  late TutorialCoachMark tutorialCoachMark;
  bool navToPlayChainCompleted = false, navToPlayWaitCompleted = false;

  TutorialCoachMark createTutorial() {
    // Start Load Sample Chains
    ChainList chainList = Provider.of<ChainList>(context, listen: false);

    // End Load Sample Chains

    List<Map<String, dynamic>> tutorialItems =
        getTutorialItemsByType(context, tutorialType, chainList);
    for (Map<String, dynamic> tutorialItem in tutorialItems) {
      Widget widgetToShow = const Text("");
      String? title;
      GlobalKey<State<StatefulWidget>>? keyTarget;
      AlignmentGeometry? focusAlign;
      ContentAlign? contentAlign;
      for (String tutorialItemKey in tutorialItem.keys) {
        switch (tutorialItemKey) {
          case "widgetToShow":
            widgetToShow = tutorialItem[tutorialItemKey] as Widget;
            break;
          case "globalKey":
            keyTarget = tutorialItem[tutorialItemKey] as GlobalKey;
            break;
          case "title":
            title = tutorialItem[tutorialItemKey] as String;
            break;
          case "contentAlign":
            contentAlign = tutorialItem[tutorialItemKey] as ContentAlign;
            break;
          case "focusAlign":
            focusAlign = tutorialItem[tutorialItemKey] as AlignmentGeometry;
            break;
        }
      }

      targets.add(
        TargetFocus(
          identify: title,
          keyTarget: keyTarget,
          alignSkip: focusAlign,
          enableOverlayTab: true,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
              align: contentAlign!,
              builder: (context, controller) {
                return Semantics(
                  label: "Tutorial Widget to show.",
                  child: widgetToShow,
                );
              },
            ),
          ],
        ),
      );
    }

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.amber,
      textSkip: "[X] Close",
      disableBackButton: false,
      textStyleSkip: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      // skipWidget: ListTile(
      //   tileColor: Colors.transparent,
      //   title: SkipButton(
      //     onPressed: null,
      //   ),
      //   subtitle: Text(
      //     "You can Tap Anywhere on the screen to move to the Next Slide",
      //     textAlign: TextAlign.center,
      //     style: Theme.of(context).textTheme.titleSmall,
      //   ),
      // ),
      paddingFocus: 10,
      opacityShadow: 0.1,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onSkip: () {
        endTutorial(context);
        return true;
      },
      onFinish: () {
        endTutorial(context);
      },
      onClickTarget: (target) {
        speakNext(context, target);
        navigateToNexScreen(context, target);
      },
      onClickTargetWithTapPosition: (target, tapDetails) async {
        speakNext(context, target);
        navigateToNexScreen(context, target);
      },
      onClickOverlay: (target) async {
        speakNext(context, target);
        navigateToNexScreen(context, target);
      },
    );
    return tutorialCoachMark;
  }

  void endTutorial(BuildContext context) async {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    chainList.stopSpeech();
    // chainList.setSetting(tutorialType, falseSettingValue);
    chainList.refresh();
    await CommonUI().dialogCheckPlayTutorialAgain(context, tutorialType);
    await chainList.setSetting(
      tutorialType,
      falseSettingValue,
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void speakNext(BuildContext context, TargetFocus target) {
    ChainList chainList = Provider.of<ChainList>(context, listen: false);
    chainList.stopSpeech();
    int targetIndex = tutorialCoachMark.targets
        .indexWhere((t) => target.identify == t.identify);
    int nextTargetIndex = (targetIndex + 1) >= tutorialCoachMark.targets.length
        ? -1
        : (targetIndex + 1);
    if (nextTargetIndex >= 0) {
      chainList.speakText(tutorialCoachMark.targets[nextTargetIndex].identify);
    }
  }

  Future<void> navigateToNexScreen(
      BuildContext context, TargetFocus target) async {
    switch (target.identify) {
      case idToGoToPlayWaitTutorialScreen:
        if (navToPlayWaitCompleted == true) {
          break;
        }
        navToPlayWaitCompleted = true;
        NavigatorState nav = Navigator.of(context);

        try {
          nav.pushNamed(
            PlayWaitActivityScreenTutorial.routename,
          );
        } catch (e) {
          endTutorial(context);
        }

        break;
      case idToGoToPlayChainScreen:
        if (navToPlayChainCompleted == true) {
          break;
        }
        navToPlayChainCompleted = true;
        NavigatorState nav = Navigator.of(context);
        try {
          Future.delayed(const Duration(milliseconds: 500), () {
            nav.pop();
          });
        } catch (e) {
          endTutorial(context);
        }

        break;
      default:
      // NavigatorState nav = Navigator.of(context);
      // nav.pop();
    }
  }

  List<Map<String, dynamic>> getTutorialItemsByType(
      BuildContext context, String tutorialType, ChainList chainList) {
    List<Map<String, dynamic>> tutorialItemType;

    switch (tutorialType) {
      case tutorialChainListScreen:
        tutorialItemType = [
          {
            "title":
                "This is the App's header with a Logo and Couple of Buttons to the right.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "ChainPlay",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Text(
                    "Chain Play is a tool to Chain your activities and Play it.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "Lets undestand the major functions of this Screen.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withValues(alpha: 0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tap the ",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              "Highlighted Area",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                            Text(
                              " to move ahead",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tap on ",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              "[X] Close",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                            Text(
                              " to end this tutorial.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.homeChainAndPlayKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title": "Press here to Create a New Chain of Activities",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Create Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This Button will take you to a form which will help you to create the Chain of Activities.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.createNewChainButtonKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "And press this one to create a new chain by uploading a file",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Upload Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This app allows us to Share the Chain or download the Chain in file format.\nThis button allows us to upload that file and create the Chain as per file configuration.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Image.asset(
                    assetMap["chain_file_view"]!,
                    fit: BoxFit.scaleDown,
                    height: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).viewPadding.top -
                            MediaQuery.of(context).viewPadding.bottom) *
                        0.50,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.uploadChainButtonKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title": "Refresh the page by tapping over the app logo here.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "App Icon",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "App Icon is not just a logo but a button to refresh the home page of this app. Action fetches the chains, activities and app settings from this app's local database.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.chainAndPlayTitle,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title": "All the Chains are listed here.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "All the Chains",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "List of all the chains present in your app. Chain Play comes with few sample chains as listed here. ",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.chainListKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title": "which you can filter using these predefined filters.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Filter Chains",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "When number of chains are high, and we are struggling to find our favorite chains or running chains then these filters can help.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.chainFiltersKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "Or search the chains with the content like Chain Title or Title of Activities in it.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Search Chains",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "You can also search the chains by tapping here, with the content like Chain Title or Title of Activities in it.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.chainListSearchkey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "You can check the quick Summary of Chain Controls like play, open, delete etcitra.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Sumary of Chain Contorls",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This section is just kept for your help to understand the set of actions that you can perform for creating chains and playing with it.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Text(
                            "1. App Header Controls",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: const AppHeaderButtonsHelp(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Text(
                            "2. Controls on a Chain Tile",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: const ChainTileHelp(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).focusColor,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Text(
                            "3. Bottom Bar Controls",
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: const AppBottomButtonsHelp(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            "globalKey": KeyHelper.chainControlSummaryKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "Let understand a tile view of a chain and the controls available on it.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Sample Workout Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Lets take this Sample Workout Chain as an example to understand a Chain and its features.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.sampleWorkoutChainListItemKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "Title of the Chain is kept here to signify that it is a Chain made up of Activities.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Chain Tile: Title",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Title of the Chain is kept here over the a Chain Image to easily identify the chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.sampleWorkoutChainTileTitleKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "This section of Tile holds the information related to the Chain like Number of Activities, Number of Executions, Chain Status if it is running and the Last Updated Date if it is not running.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Chain Tile: Status",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This section of Tile holds the information related to the Chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "If the Chain is Running then it will show the Current Activity and its stauts",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "If the Chain is NOT Running then it will show other chain information like Number of Activites, Number of Executions and the Last Updated Date.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.sampleWorkoutChainTileDescriptionKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "You can play this chain by pressing this button. Long Pressing this play button gives the option to Schedule the chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Chain Tile: Play or Schedule Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "You can play this chain by pressing this button.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    " Long Pressing this play button gives the option to Schedule the chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.sampleWorkoutChainTilePlayChainButtonKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "Here we have kept a Quick Button to perform the quick actions on this chain like Sharing it as a file, marking it as favorite.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Chain Tile: Quick Actions",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "You can marke the Chain as Favorite",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "You can share the Chain as a file with others.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.sampleWorkoutChainTileQuickButtonKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "More chain actions and detailed of the Activities in it can be explored by opening the chain by tapping on this Chain Tile.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Open Chain by Tapping on it",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "More chain actions and detailed of the Activities in it can be explored by opening the chain by tapping on this Chain Tile.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.sampleWorkoutChainListItemKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
        ];
        break;
      case tutorialViewChainScreen:
        tutorialItemType = [
          {
            "title":
                "This is a Quick tutorial to Brief you with View Chain screen functions.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: SingleChildScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      "View Chain",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "Quick tutorial to Brief you with View Chain screen functions.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap the ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "Highlighted Area",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to move ahead",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap on ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "[X] Close",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to end this tutorial.",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            "globalKey": KeyHelper.viewChainTitleKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title": "This is how a chain looks with its activities.",
            "widgetToShow": Text(
              "This is how a chain Looks.",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            "globalKey": KeyHelper.viewChainKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "This section has series of buttons to take actions on this chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Chain Actions",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Series of buttons to take actions on this chain like Play Chain, Check its execution history, mark it favorite, share or download it in file format and delete this chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.viewChainOptionsKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          // {
          //   "title":
          //       "This bottom bar contains the title of the Chain at the Center, a button to go back to home screen at the left and a button to Edit this chain at the right.",
          //   "widgetToShow": Container(
          //     padding: EdgeInsets.symmetric(horizontal: 10),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(50),
          //       color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
          //     ),
          //     child: ListView(
          //       shrinkWrap: true,
          //       children: [
          //         Text(
          //           "Bottom Bar of Chain View Screen",
          //           style: Theme.of(context).textTheme.headlineSmall,
          //         ),
          //         Text(
          //           "This bottom bar contains the title of the Chain at the Center, a button to go back to home screen at the left and a button to Edit this chain at the right.",
          //           style: Theme.of(context).textTheme.bodyLarge,
          //         ),
          //       ],
          //     ),
          //   ),
          //   "globalKey": KeyHelper.viewChainBottomBarKey,
          //   "focusAlign": Alignment.topCenter,
          //   "contentAlign": ContentAlign.top,
          // },
          {
            "title":
                "Schedule the Chain and get Notification to start the chain at the scheduled time.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Schedule the Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "We can schedule the chain by pressing this button.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.viewChainScheduleChainKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "We can play this chain by pressing this button. This button is avialable on the Chain tile at Home screen too. Also Long Pressing this play button gives the option to Schedule the chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Play the Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "We can play the chain by pressing this button.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "This button is present on home screen on the individual chain tile too.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).canvasColor,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          // tileColor: chain.chainStatus == statusDone
                          //     ? Theme.of(context).disabledColor
                          //     : Theme.of(context).cardColor,
                          // subtitle: Text(chain.title),
                          title: SingleChildScrollView(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "with",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            // color: Theme.of(context).scaffoldBackgroundColor,
                                          ),
                                    ),
                                    Text(
                                      "Activity",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    Text(
                                      "Execs",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  ],
                                ),
                                const VerticalDivider(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Last Updated",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            // color: Theme.of(context).scaffoldBackgroundColor,
                                          ),
                                    ),
                                    Text(
                                      "on ${DateFormat.yMMMd().format(DateTime.now())}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                    Text(
                                      "at ${DateFormat.Hms().format(DateTime.now())}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            radius: 25,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.play_arrow,
                              ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.share),
                              const Icon(Icons.favorite),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                assetMap["chainImage"]!,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                "Sample Chain",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      //color: Theme.of(context).hintColor,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Image.asset(
                                assetMap["chainImage"]!,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Long Pressing this play button gives the option to Schedule the chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.viewChainPlayChainKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "This bottom bar contains the title of the Chain at the Center, a button to go back to home screen at the left and a button to Edit this chain at the right.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Bottom Bar of Chain View Screen",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This bottom bar contains the title of the Chain at the Center, a button to go back to home screen at the left and a button to Edit this chain at the right.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.viewChainBottomBarKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "This Button will take you to Edit Chain screen where you will be able to edit this Chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Edit this Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This Button will take you to Edit Chain screen where you will be able to edit this Chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.viewChainEditButtonKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
        ];
        break;
      case tutorialPlayChainScreen:
        tutorialItemType = [
          {
            "title":
                "This is a Quick tutorial to Brief you with Chain Execution Status screen functions.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: SingleChildScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      "Play Chain",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "Quick tutorial to Brief you with Chain Execution Status Screen functions.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap the ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "Highlighted Area",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to move ahead",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap on ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "[X] Close",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to end this tutorial.",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            "globalKey": KeyHelper.playChainTitleKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "This screen shows the Execution status of the chain. Status of individual activities can be seen here.",
            "widgetToShow": Text(
              "Execution Status of this Chain.",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            "globalKey": KeyHelper.playChainKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "This section displays the relevant buttons to take action for running the chain. Button to resume the chain in background shall be displayed if the Current Activity is timer activity and it is paused. Button to refresh the page shall be displayed if the chain is running in background. And a button to go to the Interactive View to play the chain shall be displayed if neither the chain is running in backgroud nor it can be run.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Relevant Actions on Current Activity",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This section displays the relevant buttons to take action for running the chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  CatTextButton(
                    buttonLabel: "Cancel Schedule & Start Now",
                    buttonAction: () {},
                    buttonIcon: Icons.free_cancellation_outlined,
                  ),
                  const Text(
                    "This message shall be dispalyed when the Chain is scheduled to start. Pressing this button will cancel the schedule and start the first activity of the Chain interactively.",
                  ),
                  CatTextButton(
                    buttonLabel: "Play the Chain, in Background",
                    buttonAction: () {},
                    buttonIcon: Icons.play_circle,
                  ),
                  const Text(
                    "Button to resume the chain in background shall be displayed if the Current Activity is timer activity and it is paused",
                  ),
                  CatTextButton(
                    buttonLabel: "Refresh, for the latest status",
                    buttonAction: () {},
                    buttonIcon: Icons.refresh_outlined,
                  ),
                  const Text(
                    "Button to refresh the page shall be displayed if the chain is running in background.",
                  ),
                  CatTextButton(
                    buttonLabel: "Play the Chain, Interactively",
                    buttonAction: () {},
                    buttonIcon: Icons.arrow_forward_outlined,
                  ),
                  const Text(
                    "Button to go to the Interactive View to play the chain shall be displayed if neither the chain is running in backgroud nor it can be run.",
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playChainRunInBackgroundKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "Press here to switch between Landscape and Portrait mode.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Rotate the Screen",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Press here to switch between Landscape and Portrait mode.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playChainRotateScreenKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title": "We can use this option to stop the Chain Execution.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Stop this Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "We can use this option to stop the Chain Execution. Schedule notifications (if any) will also be cancelled on stopping the Chain Execution.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playChainStopChainKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title": idToGoToPlayWaitTutorialScreen,
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Open the Current Activity",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Press the forward button to go back to Chain Activity Execution screen, where we can resume the Chain Activity Interactively.\nIf the chain is running in background, and refresh button is also visible on the page then you will get the option to force complete the activity running in background and enter the interactive view of chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playChainForwardButtonKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "This is a Quick tutorial to Brief you with Play Activity Screen and its functions.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: SingleChildScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      "Play Chain Activity",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "This is a Quick tutorial to Brief you with Play Activity Screen and its functions.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap the ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "Highlighted Area",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to move ahead",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap on ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "[X] Close",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to end this tutorial.",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            "globalKey": KeyHelper.playWaitTitleKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "Chain Plays interactively activity by activity. This screen runs an individual activity of a chain interactively.",
            "widgetToShow": Text(
              "An activity of a Chain runs interactively on this screen.",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            "globalKey": KeyHelper.playWaitKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "We can play the chain in Landscape view too. use this button to switch between Portrait and Landscape.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Switch between Landscape & Portrait",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "use this button to switch between Portrait and Landscape.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playWaitRotateScreenKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "We can pause the chain activity and resume it back with this button and hence the chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Pause or Resume the Chain Activity",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "We can pause the chain activity and resume it back with this button and hence the chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playWaitPlayPauseKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "If Timer is taking long and you can't keep looking at the screen for so long, then use this button to Go Back to Chain Execution Status Screen and Notify when Activity is done.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Go Back to Chain Execution Status & Run in Background",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "If Timer is taking long and you can't keep looking at the screen for so long, then use this buttong to Go Back to Chain Execution Status Screen and Notify when Activity is done.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playWaitGoBackAndNotifyKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "Timer keeps ticking for the activity with Timer duration here. If the activity does not have timer then we get an option to press Done and complete the activty.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Acitivty Timer or Button to complete the Activty",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This section of screen shows the timer running in reverse. Activity will auto complete on completion of this Timer. For the Activities without Duration, we get the option to mark the activity as done here.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playWaitTimerKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "This button helps you to force complete the current activity and move to the next activity.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Go to next Activity of this Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "This button helps you to force complete the current activity and move to the next activity.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playWaitForwardKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title": idToGoToPlayChainScreen,
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Pause Chain and Go to Chain Execution Status screen.",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Press the back button to pause the Chain (if running) and go to the Screen where we can see the Chain Execution Status and take actions on the Chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.playWaitBackwardKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
        ];
        break;
      case tutorialAddChainScreen:
        tutorialItemType = [
          {
            "title":
                "This is a Quick tutorial to brief you with Edit Chain Screen. Same screen is for adding a new chain too.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: SingleChildScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      "Add/Edit Chain",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "This is a Quick tutorial to brief you with Edit Chain Screen. Same screen is for adding a new chain too.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    HomeButtonWidget(
                      chainListFunction: "navigateToAddChainScreen",
                      buttonText: "Create",
                      buttonSubText: "Your Own Chain of Timers.",
                      logo: Icon(
                        Icons.add_box_outlined,
                        size: 50,
                      ),
                    ),
                    Text(
                      "This screen also loads up when we choose to Create the Chain from Home screen.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap the ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "Highlighted Area",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to move ahead",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Tap on ",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                "[X] Close",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                              Text(
                                " to end this tutorial.",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            "globalKey": KeyHelper.addChainTitleKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title": "This screen helps you to Create or Edit the chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Create or Edit Chain Screen",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.addChainKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title": "Here we have an Editable title of chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Chain Title",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "We can see or edit the chain title here.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.addChainTitleKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
          {
            "title":
                "Here we insert the name of activity to be added to the chain.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Add activity to Chain",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Following form is used to add the activity to this chain or edit the existing activity in this chain.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.addChainAddActivityBarKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "Before submitting the activty, we can add duration to it, or an image to the activity.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Add Specifications to Activity",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "We can add the duration or an image to this activity.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    "If we will not give the duration or image then this will become a Manual Activity with a default image.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.addChainAddActivitySpecificationBarKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
          {
            "title":
                "Just press this back button when you are done with Chain Editing. It will automatically save the changes and exit from this screen.",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Save and Exit",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    "Just press this back button when you are done with Chain Editing. It will automatically save the changes and exit from this screen.",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            "globalKey": KeyHelper.addChainSaveAndExitKey,
            "focusAlign": Alignment.topCenter,
            "contentAlign": ContentAlign.top,
          },
        ];
        break;
      default:
        tutorialItemType = [
          {
            "title": "Tutorial Not defined",
            "widgetToShow": Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).canvasColor.withValues(alpha: 0.3),
              ),
              child: Text(
                "Tutorial Not defined",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            "globalKey": KeyHelper.chainListKey,
            "focusAlign": Alignment.bottomCenter,
            "contentAlign": ContentAlign.bottom,
          },
        ];
    }
    return tutorialItemType;
  }
}
