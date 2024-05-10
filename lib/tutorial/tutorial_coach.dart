import 'dart:ui';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/system_configuration.dart'
    as sysconfig;
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/tutorial/screens/add_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/play_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/screens/view_chain_screen_tutorial.dart';
import 'package:chain_activities/tutorial/widgets/skip_button.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialCoach {
  final ChainList chainList;
  final String tutorialType;

  TutorialCoach({required this.tutorialType, required this.chainList});

  List<TargetFocus> targets = [];
  late TutorialCoachMark tutorialCoachMark;
  late Chain sampleWorkoutChain;
  bool navToViewChainCompleted = false,
      navToAddChainCompleted = false,
      navBackToViewChainCompleted = false,
      navToPlayChainCompleted = false,
      navToPausedChainCompleted = false,
      navToChainExecutionStatusScreen = false,
      navToComeBackToHome = false;

  TutorialCoachMark createTutorial(BuildContext context) {
    // Start Load Sample Chains

    sampleWorkoutChain = chainList.chains.firstWhere(
        (chainElement) => chainElement.title == sampleWorkoutChainTitle,
        orElse: () => Chain());
    // End Load Sample Chains

    List<Map<String, dynamic>> tutorialItems =
        sysconfig.getTutorialItemsByType(context, tutorialType, chainList);
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
                return widgetToShow;
              },
            ),
          ],
        ),
      );
    }

    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.amber,
      skipWidget: const SkipButton(
        onPressed: null,
      ),
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

  void endTutorial(BuildContext context) {
    chainList.stopSpeech();
    chainList.setSetting(tutorialType, falseSettingValue);
    // chainList.dontShowHelpOnNextLoad();
    // chainList.showHelpOnNextLoad();
    chainList.loadSampleChainsFromAssets();
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pushReplacementNamed(ChainListScreen.routename);
  }

  void showTutorial(BuildContext context) {
    tutorialCoachMark.show(context: context);
  }

  void speakNext(BuildContext context, TargetFocus target) {
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
      // case idToShowHideAppDrawer:
      //   ScaffoldState ss = Scaffold.of(context);
      //   ss.openDrawer();
      //   await Future.delayed(const Duration(seconds: 5));
      //   ss.closeDrawer();
      //   break;
      case idToLoadSampleChainForTutorial:
        chainList.removeSampleChainsNotNeededForTutorial();
        break;
      case idToStartViewChain:
        if (navToViewChainCompleted == true) {
          break;
        }

        Navigator.of(context)
            .pushNamed(ViewChainTutorial.routename, arguments: {
          "chain": sampleWorkoutChain,
        });
        navToViewChainCompleted = true;
        break;
      case idToStartAddChain:
        if (navToAddChainCompleted == true) {
          break;
        }
        NavigatorState nav = Navigator.of(context);
        sampleWorkoutChain.edit = true;
        await chainList.updateChain(sampleWorkoutChain, false);
        await nav.pushNamed(
          AddChainScreenTutorial.routename,
          arguments: sampleWorkoutChain,
        );
        navToAddChainCompleted = true;
        break;
      case idToGoBackToViewChain:
        if (navBackToViewChainCompleted == true) {
          break;
        }
        NavigatorState nav = Navigator.of(context);
        sampleWorkoutChain.edit = false;
        await chainList.updateChain(sampleWorkoutChain, false);
        nav.pop();
        navBackToViewChainCompleted = true;
        break;
      case idToPlayChain:
        if (navToPlayChainCompleted == true) {
          break;
        }
        NavigatorState nav = Navigator.of(context);
        Chain chainExecution =
            await chainList.startChainExecution(sampleWorkoutChain);
        int runningChainActivityIndex =
            chainList.getRunningChainActivityIndex(chainExecution);
        await nav.pushNamed(
          PlayChainTutorial.routename,
          arguments: {
            payLoadChainExecId: chainExecution.chainExecutionId,
            payLoadChainName: chainExecution.title,
            payLoadChainActivityIndex:
                runningChainActivityIndex != -1 ? runningChainActivityIndex : 0,
            payLoadChainActivityCount: sampleWorkoutChain.chainHistory.length,
            payLoadChainAction: playChainActionPlay,
          },
        );
        navToPlayChainCompleted = true;
        break;
      case idToPauseTheChain:
        if (navToPausedChainCompleted == true) {
          break;
        }

        // NavigatorState nav = Navigator.of(context);
        // Chain chainExecution =
        //     await chainList.startChainExecution(sampleWorkoutChain);
        // int runningChainActivityIndex =
        //     chainList.getRunningChainActivityIndex(chainExecution);
        // nav.pop({
        //   "running": false,
        //   "waitDuration": const Duration(seconds: 10),
        //   "interruptAndCompleted": false,
        //   "resumedAt": DateTime.now(),
        // });
        // await nav.pushNamed(
        //   PlayChain.routename,
        //   arguments: {
        //     payLoadChainExecId: chainExecution.chainExecutionId,
        //     payLoadChainName: chainExecution.title,
        //     payLoadChainActivityIndex:
        //         runningChainActivityIndex != -1 ? runningChainActivityIndex : 0,
        //     payLoadChainActivityCount: sampleWorkoutChain.chainHistory.length,
        //     payLoadChainAction: playChainActionPause,
        //   },
        // );
        navToPausedChainCompleted = true;
        break;
      case idToGoToChainExecutionStatusScreen:
        if (navToChainExecutionStatusScreen == true) {
          break;
        }
        NavigatorState nav = Navigator.of(context);

        nav.pop({
          "running": false,
          "waitDuration": const Duration(seconds: 10),
          "interruptAndCompleted": false,
          "resumedAt": DateTime.now(),
        });

        navToChainExecutionStatusScreen = true;
        break;
      case idToComeBackToHome:
        if (navToComeBackToHome == true) {
          break;
        }
        await chainList.stopChainExecution(sampleWorkoutChain);
        navToComeBackToHome = true;
        break;
      default:
      // NavigatorState nav = Navigator.of(context);
      // nav.pop();
    }
  }
}
