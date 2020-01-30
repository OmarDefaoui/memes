import 'dart:convert';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:memes/Constants/AdmobId.dart';
import 'package:memes/ui/screens/ImageScreen.dart';
import 'package:memes/ui/widget/CustomCard.dart';
import 'package:memes/utils/ShowAction.dart';
import 'package:memes/utils/adBuilder.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PreloadPageController> controllers = [];

  List _memes = [];
  bool _isError = false, _isDataLoaded = false, _isLoadingMore = false;
  int _totalItems = 0, _itemCount = 5;

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    controllers = [
      PreloadPageController(viewportFraction: 0.6, initialPage: 1),
      PreloadPageController(viewportFraction: 0.6, initialPage: 1),
      PreloadPageController(viewportFraction: 0.6, initialPage: 1),
      PreloadPageController(viewportFraction: 0.6, initialPage: 1),
      PreloadPageController(viewportFraction: 0.6, initialPage: 1),
    ];
    controllers[0].addListener(() {
      if ((controllers[0].position.pixels ==
              controllers[0].position.maxScrollExtent) &&
          !_isLoadingMore &&
          _totalItems - _itemCount >= 5) {
        _isLoadingMore = true;
        _loadMore();
      }
    });
    _getJsonData();
    _initAds();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    for (int i = 0; i < 5; i++) controllers[i].dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _isError
                ? Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 50,
                      ),
                      alignment: Alignment.center,
                      onPressed: () {
                        setState(() {
                          _isError = false;
                          _isDataLoaded = false;
                        });
                        _refreshList();
                      },
                    ),
                  )
                : _isDataLoaded
                    ? PreloadPageView.builder(
                        physics: BouncingScrollPhysics(),
                        controller: PreloadPageController(
                          viewportFraction: 0.7,
                          initialPage: 2,
                        ),
                        itemCount: 5,
                        preloadPagesCount: 5,
                        itemBuilder: (context, mainIndex) {
                          return RefreshIndicator(
                            onRefresh: _refreshList,
                            child: PreloadPageView.builder(
                              itemCount: _itemCount,
                              preloadPagesCount: _itemCount,
                              controller: controllers[mainIndex],
                              scrollDirection: Axis.vertical,
                              physics: BouncingScrollPhysics(),
                              onPageChanged: (page) {
                                _animatePage(
                                  page,
                                  mainIndex,
                                );
                              },
                              itemBuilder: (context, index) {
                                var memeIndex =
                                    (mainIndex * _itemCount) + index;
                                var memeUrl;
                                memeUrl =
                                    _memes[memeIndex]['node']['display_url'];

                                return GestureDetector(
                                  onTap: () {
                                    try {
                                      _bannerAd?.dispose();
                                    } catch (error) {
                                      print('error closing banner ad: $error');
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageScreen(
                                          url: memeUrl,
                                          showBanner: showBanner,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: memeUrl,
                                    child: CustomCard(
                                      url: memeUrl,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.topRight,
            margin: EdgeInsets.all(10),
            child: SafeArea(
              child: FloatingActionButton(
                child: customPopUpMenu(),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _refreshList() async {
    _memes = [];
    _isError = false;
    _isDataLoaded = false;
    _isLoadingMore = true;
    _totalItems = 0;
    _itemCount = 5;

    await _getJsonData();
    _isLoadingMore = false;
    return 'Success';
  }

  _loadMore() {
    bool _canLoadMore = (_totalItems - _itemCount * 5) >= 25;

    if (_canLoadMore) {
      print('load more');
      setState(() {
        _itemCount += 5;
      });
    }
    _isLoadingMore = false;
  }

  Future<String> _getJsonData() async {
    print('fetch data call');
    var response = await http
        .get(
      Uri.encodeFull(
        'https://www.instagram.com/explore/tags/memesdaily/?__a=1',
      ),
    )
        .catchError((error) {
      print('error: $error');
      setState(() {
        _isError = true;
      });
      return 'Error';
    });

    var convertDataToJson;
    try {
      convertDataToJson = await json.decode(response.body);
    } catch (error) {
      print('error: $error');

      setState(() {
        _isError = true;
      });
      return "Error";
    } finally {
      _memes = convertDataToJson['graphql']['hashtag']['edge_hashtag_to_media']
          ['edges'];
      _totalItems = _memes.length;

      print(_totalItems.toString());
      print(_memes[0]['node']['display_url']);

      setState(() {
        _isDataLoaded = true;
      });
      print('succes');
    }

    return "Success";
  }

  _animatePage(int page, int index) {
    for (int i = 0; i < 5; i++) {
      if (i != index) {
        controllers[i].animateToPage(
          page,
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  _initAds() {
    FirebaseAdMob.instance.initialize(appId: admobAppId);

    Future.delayed(const Duration(seconds: 1), () {
      showBanner();

      _interstitialAd = createInterstitialAd(1)
        ..load()
        ..show();
    });
  }

  showBanner() {
    print('show banner call');
    _bannerAd = createBannerAd(1)
      ..load()
      ..show();
  }
}
