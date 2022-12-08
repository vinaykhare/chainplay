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
                  image: const AssetImage("assets/logo/logo.png"),
                  fit: BoxFit.fill,
                  height: appHeight * 0.5,
                ),
                Text(
                  "Loading...",
                  style: Theme.of(context).textTheme.headline4?.copyWith(
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
