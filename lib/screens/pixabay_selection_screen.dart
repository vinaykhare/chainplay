import 'package:flutter/material.dart';

class PixabaySelectionScreen extends StatefulWidget {
  static String routename = "pixabay_selection";

  const PixabaySelectionScreen({
    super.key,
  });
  @override
  State<PixabaySelectionScreen> createState() => _PixabaySelectionScreenState();
}

class _PixabaySelectionScreenState extends State<PixabaySelectionScreen> {
  bool initializing = true;
  String activityTitle = "";
  List<String?> pixabayLinks = [];
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      Map<String, dynamic> input =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      pixabayLinks = input["pixabayLinks"];
      activityTitle = input["activityTitle"];
      initializing = false;
    }

    return Semantics(
      label: "Pixabay Selection Screen",
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          title: Text(
            "Images matching the Activity Title: $activityTitle",
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        body: SafeArea(
          child: GridView.builder(
            itemCount: pixabayLinks.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              String link = pixabayLinks[index] ?? "";
              return link != ""
                  ? Padding(
                      padding: EdgeInsets.all(5),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(link),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null;
            },
          ),
        ),
      ),
    );
  }
}
