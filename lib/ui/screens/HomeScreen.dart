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
  bool _isError = false, _isDataLoaded = false;
  int _itemCount = 5;

  @override
  void initState() {
    super.initState();
    getJsonData();
    controllers = [
      PreloadPageController(viewportFraction: 0.6, initialPage: 3),
      PreloadPageController(viewportFraction: 0.6, initialPage: 3),
      PreloadPageController(viewportFraction: 0.6, initialPage: 3),
      PreloadPageController(viewportFraction: 0.6, initialPage: 3),
      PreloadPageController(viewportFraction: 0.6, initialPage: 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).backgroundColor,
      body: _isError
          ? Center(
              child: Text('Error'),
            )
          : _isDataLoaded
              ? PreloadPageView.builder(
                physics: BouncingScrollPhysics(),
                  controller: PreloadPageController(
                    viewportFraction: 0.7,
                    initialPage: 3,
                  ),
                  itemCount: 5,
                  preloadPagesCount: 5,
                  itemBuilder: (context, mainIndex) {
                    return PreloadPageView.builder(
                      itemCount: 5,
                      preloadPagesCount: 5,
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
                        var memeIndex = (mainIndex * 5) + index;
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
                          child: CustomCard(
                            url: memeUrl,
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

  Future<String> getJsonData() async {
    print('fetch data call');
    var response = await http.get(
      Uri.encodeFull(
        'https://www.instagram.com/explore/tags/memesdaily/?__a=1',
      ),
    );

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
      _memes = (convertDataToJson['graphql']['hashtag']['edge_hashtag_to_media']
          ['edges']);

      print(_memes.length.toString());
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
