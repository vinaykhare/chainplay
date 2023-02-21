import 'package:chain_activities/helpers/constants.dart';
import 'package:flutter/material.dart';

class LoadScreen extends StatelessWidget {
  static String routename = "/load_screen";
  const LoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).primaryColor,
          height: appHeight,
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(
                  image: AssetImage(assetMap['logoImage']!),
                  fit: BoxFit.fill,
                  height: appHeight * 0.5,
                ),
                Text(
                  "Loading CTA...",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
