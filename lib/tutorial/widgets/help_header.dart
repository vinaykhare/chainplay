import 'dart:async';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/system_configuration.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
import 'package:chain_activities/tutorial/screens/chain_list_screen_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelpHeader extends StatefulWidget {
  final double appHeight;
  final double appWidth;
  const HelpHeader(
      {super.key, required this.appHeight, required this.appWidth});

  @override
  State<HelpHeader> createState() => _HelpHeaderState();
}

class _HelpHeaderState extends State<HelpHeader> {
  int page = 0;
  Timer? countdownTimer;
  late ChainList chainList;
  bool isNotPlaying = false;
  bool initConfig = true;

  // void startTimer() {
  //   countdownTimer = Timer.periodic(
  //     const Duration(
  //       seconds: 20,
  //     ),
  //     (_) async {
  //       setState(() {
  //         incrementPage();
  //       });
  //       // Provider.of<ChainList>(context, listen: false).checkAndUpdateConfig();
  //     },
  //   );
  // }

  // void stopTimer() {
  //   setState(() {
  //     if (countdownTimer != null) countdownTimer?.cancel();
  //   });
  // }

  // void resetTimer() {
  //   stopTimer();
  //   startTimer();
  // }

  void incrementPage() async {
    if (page < (headerSlideContent.length - 1)) {
      page++;
      await speak();
    } else {
      NavigatorState nav = Navigator.of(context);
      await chainList.stopSpeech();
      nav.pushReplacementNamed(ChainListScreenTutorial.routename);
    }
  }

  void decrementPage() async {
    if (page > 0) {
      page--;
      await speak();
    } else {
      NavigatorState nav = Navigator.of(context);
      await chainList.stopSpeech();
      await chainList.setSetting(showHelpOnNextBootKey, falseSettingValue);
      nav.pushReplacementNamed(ChainListScreen.routename);
    }
  }

  Future<void> speak() async {
    // setState(() {
    //   isNotPlaying = chainList.isTtsPlaying();
    // });

    isNotPlaying = await chainList.stopSpeech();

    setState(() {
      isNotPlaying = chainList.isTtsPlaying();
    });
    isNotPlaying = await chainList.speakText(
      headerSlideContent[page]["speech"]!,
    );
    setState(() {
      isNotPlaying = chainList.isTtsPlaying();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (initConfig) {
      chainList = Provider.of<ChainList>(context, listen: true);
      Future.delayed(
        const Duration(
          seconds: 3,
        ),
      );
      speak();
      initConfig = false;
    }
    double appHeight = widget.appHeight - 48;

    return GestureDetector(
      onTap: () {
        incrementPage();
      },
      onHorizontalDragEnd: isNotPlaying
          ? (details) {
              setState(() {
                if ((details.primaryVelocity ?? 0) < 0) {
                  // Page forwards
                  incrementPage();
                } else if ((details.primaryVelocity ?? 0) > 0) {
                  // Page backwards
                  decrementPage();
                }
                // resetTimer();
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          key: ValueKey(page),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // SizedBox(
            //   height: appHeight * 0.05,
            // ),
            Column(
              children: [
                SizedBox(
                  height: appHeight * 0.75,
                  child: headerSlideContent[page]["imageNetwork"] == ""
                      ? Image.asset(
                          headerSlideContent[page]["imageAsset"]!,
                          //fit: BoxFit.cover,
                        )
                      : FadeInImage(
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            headerSlideContent[page]["imageAsset"]!,
                            //fit: BoxFit.cover,
                          ),
                          placeholder: AssetImage(
                              headerSlideContent[page]["imageAsset"]!),
                          image: NetworkImage(
                              headerSlideContent[page]["imageNetwork"]!),
                          //fit: BoxFit.fill,
                        ),
                ),
                ListTile(
                  title: Text(
                    headerSlideContent[page]["title"]!,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    headerSlideContent[page]["subtitle"]!,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            if (isNotPlaying)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => setState(() {
                      decrementPage();
                    }),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            page > 0 ? Icons.skip_previous : Icons.home,
                          ),
                        ),
                        Text(page > 0 ? "Previous" : "Skip & Go Home"),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      speak();
                      // resetTimer();
                    }),
                    icon: const Icon(
                      Icons.refresh,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // TextButton(
                      //   onPressed: () => setState(() {
                      //     incrementPage();
                      //     // resetTimer();
                      //   }),
                      //   child: const Text(
                      //     // page < (headerSlideContent.length - 1)
                      //     //     ? "Next"
                      //     //     : "Done",
                      //     "Next",
                      //     textAlign: TextAlign.right,
                      //   ),
                      // ),
                      InkWell(
                        onTap: () => setState(() {
                          incrementPage();
                          // resetTimer();
                        }),
                        child: Row(
                          children: [
                            Text(page == (headerSlideContent.length - 1)
                                ? "Start Tutorial"
                                : "Next"),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                page == (headerSlideContent.length - 1)
                                    ? Icons.play_lesson_outlined
                                    : Icons.skip_next,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              IconButton(
                onPressed: () async {
                  isNotPlaying = await chainList.stopSpeech();
                  await Future.delayed(
                    const Duration(
                      microseconds: 1,
                    ),
                  );
                  setState(() {
                    isNotPlaying = !chainList.isTtsPlaying();
                  });
                },
                icon: const Icon(
                  Icons.volume_up_outlined,
                ),
              ),

            // Container(
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha:
            //           0.3,
            //         ),
            //     borderRadius: const BorderRadius.all(
            //       Radius.circular(20),
            //     ),
            //   ),
            //   child: SizedBox(
            //     height: 30,
            //     child: ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemExtent: 25,
            //       shrinkWrap: true,
            //       padding: EdgeInsets.zero,
            //       itemCount: headerSlideContent.length,
            //       itemBuilder: (context, index) {
            //         return TextButton(
            //           onPressed: isNotPlaying
            //               ? () {
            //                   setState(() {
            //                     page = index;
            //                     // resetTimer();
            //                     speak();
            //                   });
            //                 }
            //               : null,
            //           child: Text(
            //             //(index + 1).toString(),
            //             "o",
            //             style: TextStyle(
            //                 color: page == index
            //                     ? Theme.of(context).primaryColorDark
            //                     : Theme.of(context).primaryColorLight),
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
