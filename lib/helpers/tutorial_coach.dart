import 'dart:ui';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/system_configuration.dart'
    as sysconfig;
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TutorialCoach {
  final ChainList chainList;
  final String tutorialType;

  TutorialCoach({required this.tutorialType, required this.chainList});

  List<TargetFocus> targets = [];
  late TutorialCoachMark tutorialCoachMark;

  TutorialCoachMark createTutorial(BuildContext context) {
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
      textSkip: "Skip the Tutorial",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onSkip: () {
        chainList.stopSpeech();
        chainList.setSetting(tutorialType, falseSettingValue);
        return true;
      },
      onFinish: () {
        chainList.setSetting(tutorialType, falseSettingValue);
      },
      onClickTarget: (target) {
        moveNext(context, target);
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        moveNext(context, target);
        if (target.identify ==
            "Now Lets take this Sample Workout Chain as an example to understand, what is chain?") {
          Chain sampleWorkoutChain = chainList.chains.firstWhere(
              (chainElement) => chainElement.title == sampleWorkoutChainTitle,
              orElse: () => Chain());
          Navigator.of(context).pushNamed(ViewChain.routename, arguments: {
            "chain": sampleWorkoutChain,
          });
        }
      },
      onClickOverlay: (target) {
        moveNext(context, target);
        if (target.identify ==
            "Now Lets take this Sample Workout Chain as an example to understand, what is chain?") {
          Chain sampleWorkoutChain = chainList.chains.firstWhere(
              (chainElement) => chainElement.title == sampleWorkoutChainTitle,
              orElse: () => Chain());
          Navigator.of(context).pushNamed(ViewChain.routename, arguments: {
            "chain": sampleWorkoutChain,
          });
        }
      },
    );
    return tutorialCoachMark;
  }

  void showTutorial(BuildContext context) {
    tutorialCoachMark.show(context: context);
  }

  void moveNext(BuildContext context, TargetFocus target) {
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
}
