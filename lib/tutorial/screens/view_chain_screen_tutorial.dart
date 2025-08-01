import 'package:chain_activities/helpers/key_helper.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/helpers/constants.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';
import 'package:chain_activities/widgets/chain_activities_widget.dart';

class ViewChainTutorial extends StatefulWidget {
  static String routename = "view_chain_tutorial";
  const ViewChainTutorial({super.key});
  @override
  State<ViewChainTutorial> createState() => _ViewChainTutorialState();
}

class _ViewChainTutorialState extends State<ViewChainTutorial> {
  late Chain chain;
  late Chain parentChainItem;
  late ChainList chainList;
  int invokeCounter = 0;
  bool initializing = true, savedInDb = true, invalidChain = false;
  //bool buildDone = false;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     buildDone = true;
  //   });
  // }

  Widget getIconForChain(Chain chain) {
    if (chain.notificationId == trueInDB) {
      return const Icon(Icons.schedule);
    }
    if (chain.chainStatus == statusExecuting) {
      return const Icon(Icons.pause_circle_outline_rounded);
    }
    return const Icon(Icons.play_arrow_outlined);
  }

  //Build Function

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      chainList = Provider.of<ChainList>(context, listen: false);

      // if (chainList.notificationCameForChain != null) {
      //   chain = chainList.notificationCameForChain!;
      //   chainList.notificationCameForChain = null;
      // } else {

      Map<String, dynamic> viewArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      chain = viewArgs['chain'];
      savedInDb = viewArgs['savedInDb'] ?? true;
      invalidChain = viewArgs['invalidChain'] ?? false;
      initializing = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return IgnorePointer(
      ignoring: true,
      child: Semantics(
        label: "View Chain Screen Tutorial",
        child: PopScope(
          canPop: false,
          child: Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(
                child: SizedBox(
                  // margin: const EdgeInsets.only(top: 50),
                  // padding: const EdgeInsets.all(10),
                  height: appHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        key: KeyHelper.viewChainKey,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChainActivitiesWidget(
                            tempChain: chain,
                            editActivity: null,
                            undoEdit: null,
                          ),
                        ),
                      ),
                      Row(
                        key: KeyHelper.viewChainOptionsKey,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.delete_forever_outlined),
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.download),
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined),
                            ),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              icon: chain.pinned
                                  ? const Icon(Icons.favorite)
                                  : const Icon(Icons.favorite_border_outlined),
                              onPressed: () {},
                            ),
                          ),
                          CircleAvatar(
                            key: KeyHelper.viewChainScheduleChainKey,
                            child: Icon(Icons.alarm_outlined),
                          ),
                          CircleAvatar(
                            child: IconButton(
                              key: KeyHelper.viewChainPlayChainKey,
                              onPressed: () {},
                              icon: getIconForChain(chain),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        key: KeyHelper.viewChainBottomBarKey,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Text(
                            chain.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              key: KeyHelper.viewChainEditButtonKey,
                              Icons.edit,
                              color: invalidChain ||
                                      chain.chainStatus == statusExecuting ||
                                      !savedInDb
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
