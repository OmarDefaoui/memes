import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  final String url;
  ImageScreen({this.url});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (_controller.isCompleted) {
                    _controller.reverse();
                  } else {
                    _controller.forward();
                  }
                },
                child: CachedNetworkImage(
                  imageUrl: widget.url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(0, -_controller.value * 64),
                    child: Container(
                      height: 64.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor,
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Visibility(
                            visible: true,
                            child: Container(
                              height: 64.0,
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FlatButton(
                                child: Text('Set as wallpaper'),
                                onPressed: () {},
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, _controller.value * 64),
                    child: Container(
                      height: 64.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor,
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {},
                            ),
                            Visibility(
                              visible: false,
                              child: IconButton(
                                icon: Icon(Icons.file_download),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
