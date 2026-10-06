import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/helpers/key_helper.dart';
import 'package:chain_activities/screens/add_chain_screen.dart';
import 'package:chain_activities/screens/search_chain_screen.dart';
import 'package:chain_activities/screens/settings_screen.dart';
import 'package:chain_activities/screens/view_chain_screen.dart';
import 'package:chain_activities/widgets/chain_list_header.dart';
import 'package:chain_activities/widgets/list_of_chains.dart';
import 'package:chain_activities/widgets/no_chains_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' hide KeyHelper;
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/app_drawer.dart';
//import 'package:chain_activities/widgets/app_drawer.dart';

class ChainListScreen extends StatefulWidget {
  static String routename = "/chains";

  const ChainListScreen({super.key});

  @override
  State<ChainListScreen> createState() => _ChainListScreenState();
}

class _ChainListScreenState extends State<ChainListScreen> {
  bool showFavorites = false, showRunning = false, initialize = true;
  late ChainList chainList;
  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
  }

  // late ChainList chainList;
  @override
  Widget build(BuildContext context) {
    if (initialize) {
      chainList = Provider.of<ChainList>(context, listen: true);
      initialize = false;
    }
    List<Chain> chains = chainList.chains;
    final appBarWidget = AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      title: TextField(
        key: KeyHelper.chainListSearchkey,
        keyboardType: TextInputType.none,
        cursorColor: Theme.of(context).cardColor,
        showCursor: false,
        onTap: () =>
            Navigator.of(context).pushNamed(SearchChainScreen.routename),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          label: const Text("Search Chains"),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary,
              width: 0,
            ),
            // borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
    // double appHeight =
    //     MediaQuery.of(context).size.height - appBarWidget.preferredSize.height;
    return Semantics(
      label: "Home Screen with list of chains and other options.",
      child: Scaffold(
        drawer: const AppDrawer(),
        body: SafeArea(
          child: Material(
            elevation: 5.0,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: OrientationBuilder(builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const ChainListHeader(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              // IconButton(
                              //   icon: const Icon(Icons.menu),
                              //   onPressed: () {
                              //     Scaffold.of(context).openDrawer();
                              //   },
                              // ),

                              IconButton(
                                icon: ImageIcon(
                                  AssetImage(assetMap["logoImage"]!),
                                ),
                                onPressed: () {
                                  ChainList chainList = Provider.of<ChainList>(
                                      context,
                                      listen: false);
                                  chainList.refresh();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  while (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                  Navigator.of(context).pushReplacementNamed(
                                      AddChainScreen.routename);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.upload),
                                onPressed: () async {
                                  NavigatorState nav = Navigator.of(context);
                                  ChainList chainList = Provider.of<ChainList>(
                                      context,
                                      listen: false);
                                  FilePickerResult? result =
                                      await FilePicker.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ["json"],
                                  );

                                  if (result != null) {
                                    Chain? chain = await chainList
                                        .uploadChain(result.files.single.path!);
                                    nav.pushNamed(
                                      ViewChain.routename,
                                      arguments: {
                                        "chain": chain ?? Chain(),
                                        "savedInDb": false,
                                        "invalidChain": chain == null,
                                      },
                                    );
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(SearchChainScreen.routename);
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            while (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                            Navigator.of(context)
                                .pushReplacementNamed(SettingsScreen.routename);
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            (chains.isNotEmpty)
                                ? Expanded(
                                    child: ListOfChains(
                                      textFilter: null,
                                      showAd: true,
                                      showChainControlSummary: true,
                                      showChainInReverse: false,
                                      showFavorites: showFavorites,
                                      showRunning: showRunning,
                                    ),
                                  )
                                : const Expanded(child: NoChainsView()),
                          ],
                        ),
                      ),
                    ),
                    // appBarWidget,
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ChainListHeader(),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            (chains.isNotEmpty)
                                ? Expanded(
                                    child: ListOfChains(
                                      textFilter: null,
                                      showAd: true,
                                      showChainControlSummary: true,
                                      showChainInReverse: false,
                                      showFavorites: showFavorites,
                                      showRunning: showRunning,
                                    ),
                                  )
                                : const Expanded(child: NoChainsView()),
                          ],
                        ),
                      ),
                    ),
                    appBarWidget,
                  ],
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}
