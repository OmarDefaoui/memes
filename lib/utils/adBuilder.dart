import 'package:firebase_admob/firebase_admob.dart';
import 'package:memes/Constants/AdmobId.dart';

BannerAd createBannerAd(int id) {
  return BannerAd(
    adUnitId: id == 1 ? bannerAdUnit1 : bannerAdUnit2,
    size: AdSize.banner,
    listener: (MobileAdEvent event) {
      print("BannerAd event $event");
    },
  );
}

InterstitialAd createInterstitialAd(int id) {
  return InterstitialAd(
    adUnitId: id == 1 ? interstitialAdUnit1 : interstitialAdUnit2,
    listener: (MobileAdEvent event) {
      print("InterstitialAd event $event in $id");
    },
  );
}
