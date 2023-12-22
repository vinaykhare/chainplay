import 'package:chain_activities/models/chain_list.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

class ShowBannerAd extends StatefulWidget {
  const ShowBannerAd({super.key});

  @override
  State<ShowBannerAd> createState() => _ShowBannerAdState();
}

class _ShowBannerAdState extends State<ShowBannerAd> {
  late ChainList chainList;
  late BannerAd adBanner;

  @override
  void initState() {
    super.initState();
    chainList = Provider.of<ChainList>(context, listen: false);
    adBanner = chainList.addBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    adBanner.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
      ),
      child: AdWidget(
        ad: adBanner,
      ),
    );
  }
}
