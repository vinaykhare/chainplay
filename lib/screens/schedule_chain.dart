import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chain_activities/models/chain.dart';
import 'package:chain_activities/models/chain_list.dart';

class ScheduleChainScreen extends StatefulWidget {
  static String routename = "schedule_chain";
  const ScheduleChainScreen({super.key});
  @override
  State<ScheduleChainScreen> createState() => _ScheduleChainScreenState();
}

class _ScheduleChainScreenState extends State<ScheduleChainScreen> {
  late Chain chain;
  late Chain parentChainItem;
  late ChainList chainList;
  int invokeCounter = 0;
  bool initializing = true, savedInDb = true, invalidChain = false;

  Future<bool> onPopOut(bool didPop) async {
    if (didPop) {
      return true;
    }
    await chainList.cancelIntentSubscription();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (initializing) {
      chainList = Provider.of<ChainList>(context, listen: false);

      Map<String, dynamic> viewArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      chain = viewArgs['chain'];

      initializing = false;
    }
    double appHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top -
        MediaQuery.of(context).viewPadding.bottom;
    return Semantics(
      label: "Schedule Chain Screen",
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => onPopOut(didPop),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SafeArea(
              child: SizedBox(
                // margin: const EdgeInsets.only(top: 50),
                // padding: const EdgeInsets.all(10),
                height: appHeight,
                child: ListTile(
                  title: Text(chain.title),
                  subtitle: Text(
                    chain.at != null
                        ? DateFormat.yMMMd().add_jm().format(chain.at!)
                        : "No Scheduled Time",
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (chain.at == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No Scheduled Time Set"),
                  ),
                );
                return;
              }
            },
            tooltip: "Schedule Chain",
            child: const Icon(Icons.schedule),
          ),
          appBar: AppBar(
            title: Text("Schedule Chain"),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  // await chainList.saveChain(chain);
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text("Chain Scheduled Successfully"),
                  //   ),
                  // );
                },
              ),
            ],
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
        ),
      ),
    );
  }
}
