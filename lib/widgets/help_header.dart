import 'dart:async';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/system_configuration.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/screens/chain_list_screen.dart';
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

  @override
  void initState() {
    super.initState();
    chainList = Provider.of<ChainList>(context, listen: false);
    speak();
    //startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    // Future.delayed(
    //   const Duration(seconds: 2),
    // );
    //if (countdownTimer != null) countdownTimer?.cancel();
    chainList.stopSpeech();
  }

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

  void incrementPage() {
    if (page < (headerSlideContent.length - 1)) {
      page++;
    } else {
      page = 0;
    }
    speak();
  }

  void decrementPage() {
    if (page > 0) {
      page--;
    } else {
      page = headerSlideContent.length - 1;
    }
    speak();
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
    double appHeight = widget.appHeight - 48;
    double appWidth = widget.appWidth;
    return Container(
      //margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.background,
          ],
        ),
        // image: DecorationImage(
        //   opacity: 0.1,
        //   image: AssetImage(
        //     assetMap['logoImage']!,
        //   ),
        //   fit: BoxFit.contain,
        // )
        // borderRadius: const BorderRadius.all(
        //   Radius.circular(20),
        // ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Container(
          //   decoration: BoxDecoration(
          //     color: Theme.of(context).scaffoldBackgroundColor.withOpacity(
          //           0.3,
          //         ),
          //     borderRadius: const BorderRadius.all(
          //       Radius.circular(20),
          //     ),
          //   ),
          //   padding: const EdgeInsets.all(7),
          //   child: Text(
          //     "How 'Chain Activities' can help?",
          //     style: Theme.of(context).textTheme.titleLarge,
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          // const Divider(),
          FittedBox(
            //height: 80,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 15, 50, 0),
              child: Text(
                headerSlideContent[page]["title"]!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          GestureDetector(
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
            child: SizedBox(
              // width: appWidth * 0.3,
              width: appWidth,
              height: appHeight - 65,
              child: headerSlideContent[page]["imageAsset"] != "" &&
                      headerSlideContent[page]["imageAsset"] != null
                  ? Image.asset(
                      headerSlideContent[page]["imageAsset"]!,
                      fit: BoxFit.contain,
                    )
                  : InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(ChainListScreen.routename);
                      },
                      child: Image.asset(
                        assetMap["go_home"]!,
                        fit: BoxFit.contain,
                      ),
                    ),
            ),
          ),
          if (isNotPlaying)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => page > 0
                          ? setState(() {
                              decrementPage();
                              // resetTimer();
                            })
                          : Navigator.of(context)
                              .pushNamed(ChainListScreen.routename),
                      icon: const Icon(
                        Icons.skip_previous,
                      ),
                    ),
                    TextButton(
                      onPressed: () => page > 0
                          ? setState(() {
                              decrementPage();
                              // resetTimer();
                            })
                          : Navigator.of(context)
                              .pushNamed(ChainListScreen.routename),
                      child: Text(page > 0 ? "Previous" : "CAT Home"),
                    ),
                  ],
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
                    TextButton(
                      onPressed: () => page < (headerSlideContent.length - 1)
                          ? setState(() {
                              incrementPage();
                              // resetTimer();
                            })
                          : Navigator.of(context)
                              .pushNamed(ChainListScreen.routename),
                      child: Text(
                        page < (headerSlideContent.length - 1)
                            ? "Next"
                            : "Done",
                        textAlign: TextAlign.right,
                      ),
                    ),
                    IconButton(
                      onPressed: () => page < (headerSlideContent.length - 1)
                          ? setState(() {
                              incrementPage();
                              // resetTimer();
                            })
                          : Navigator.of(context)
                              .pushNamed(ChainListScreen.routename),
                      icon: const Icon(
                        Icons.skip_next,
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
          //     color: Theme.of(context).scaffoldBackgroundColor.withOpacity(
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
    );
  }
}
