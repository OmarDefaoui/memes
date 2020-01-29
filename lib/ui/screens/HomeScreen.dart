import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:memes/ui/screens/ImageScreen.dart';
import 'package:memes/ui/widget/CustomCard.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).backgroundColor,
      body: _isError
          ? Center(
              child: Icon(
                Icons.error_outline,
                size: 50,
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
                    return PreloadPageView.builder(
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
                        var memeIndex = (mainIndex * _itemCount) + index;
                        var memeUrl;
                        if (_memes != null) {
                          memeUrl = _memes[memeIndex]['node']['thumbnail_src'];
                        }
                        return GestureDetector(
                          onTap: () {
                            if (_memes != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageScreen(
                                    url: memeUrl,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Hero(
                            tag: memeUrl,
                            child: CustomCard(
                              url: memeUrl,
                              index: index,
                              memeIndex: memeIndex,
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
    );
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
      print(_memes[0]['node']['thumbnail_src']);

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
}
