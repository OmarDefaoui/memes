import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:memes/Constants/Constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class ImageScreen extends StatefulWidget {
  final String url;
  ImageScreen({this.url});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  ScreenshotController screenshotController = ScreenshotController();
  bool _isLoading = false, _isSavedToGallery = false;

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
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: <Widget>[
                Screenshot(
                  controller: screenshotController,
                  child: Container(
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
                      child: Hero(
                        tag: widget.url,
                        child: CachedNetworkImage(
                          imageUrl: widget.url,
                          fit: BoxFit.contain,
                        ),
                      ),
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
                          child: Container(
                            padding: const EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
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
                            child: _isLoading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          _isSavedToGallery
                                              ? Icons.check_circle_outline
                                              : Icons.save,
                                        ),
                                        onPressed: _isSavedToGallery
                                            ? () {}
                                            : _askForPermission,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.share),
                                        onPressed: _shareImage,
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
            );
          },
        ),
      ),
    );
  }

  _shareImage() async {
    setState(() {
      _isLoading = true;
    });
    screenshotController.capture().then((File image) async {
      print("Capture Done");
      File _image = image;

      try {
        await Share.file('Share', 'image_result.png',
            _image.readAsBytesSync().buffer.asUint8List(), 'image/png',
            text: '$shareBody');

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('error: $e');
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  _saveImageToGallery() async {
    setState(() {
      _isLoading = true;
    });

    screenshotController.capture().then((File image) async {
      print("Capture Done");
      File _image = image;
      print('${_image.path}');

      try {
        GallerySaver.saveImage(_image.path).then((bool result) {
          print('res: $result');
          setState(() {
            if (result) _isSavedToGallery = true;
            _isLoading = false;
          });
        });
      } catch (e) {
        print('error: $e');
      }
    }).catchError((onError) {
      print('error: $onError');
      print(onError);
    });
  }

  _askForPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    print('${permissions[PermissionGroup.storage]}');
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted)
      _showConfirmationDialog();
    else
      _saveImageToGallery();
  }

  _showConfirmationDialog() {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            content: Text(
              "This permission is required to save images to gallery.",
            ),
            title: Text("Warning !"),
            actions: <Widget>[
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: Text("Accept"),
                onPressed: () {
                  Navigator.pop(context, true);
                  _askForPermission();
                },
              ),
            ],
          );
        });
  }
}
