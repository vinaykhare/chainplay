import 'dart:async';

import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/system_configuration.dart';
import 'package:chain_activities/models/chain_list.dart';
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

  @override
  void initState() {
    super.initState();
    countdownTimer = Timer.periodic(
      const Duration(
        seconds: 15,
      ),
      (_) async {
        setState(() {
          incrementPage();
        });
        Provider.of<ChainList>(context, listen: false).checkAndUpdateConfig();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (countdownTimer != null) countdownTimer?.cancel();
  }

  void incrementPage() {
    if (page < (headerSlideContent.length - 1)) {
      page++;
    } else {
      page = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double appHeight = widget.appHeight - 70;
    double appWidth = widget.appWidth;
    return Container(
      //margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.background,
            ],
          ),
          image: DecorationImage(
            opacity: 0.1,
            image: AssetImage(
              assetMap['logoImage']!,
            ),
            fit: BoxFit.contain,
          )
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
          const Divider(),
          GestureDetector(
            onHorizontalDragEnd: (details) {
              setState(() {
                if ((details.primaryVelocity ?? 0) < 0) {
                  // Page forwards
                  incrementPage();
                } else if ((details.primaryVelocity ?? 0) > 0) {
                  // Page backwards
                  if (page > 0) {
                    page--;
                  } else {
                    page = headerSlideContent.length - 1;
                  }
                }
              });
            },
            child: Row(
              children: [
                SizedBox(
                  // width: appWidth * 0.3,
                  width: appWidth,
                  height: appHeight,
                  child: Image.asset(
                    headerSlideContent[page]["imageAsset"]!,
                    fit: BoxFit.contain,
                  ),
                ),
                // SizedBox(
                //   width: appWidth * 0.7,
                //   height: 100,
                //   child: Padding(
                //     padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                //     child: Text(
                //       headerSlideContent[page]["content"]!,
                //       style: Theme.of(context).textTheme.titleLarge,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(
                    0.3,
                  ),
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemExtent: 25,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: headerSlideContent.length,
                itemBuilder: (context, index) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        page = index;
                      });
                    },
                    child: Text(
                      //(index + 1).toString(),
                      "o",
                      style: TextStyle(
                          color: page == index
                              ? Theme.of(context).primaryColorDark
                              : Theme.of(context).primaryColorLight),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
