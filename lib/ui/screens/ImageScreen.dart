import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:memes/Constants/Constants.dart';
import 'package:memes/utils/SetWallpaper.dart';
import 'package:memes/utils/ShowAction.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class ImageScreen extends StatefulWidget {
  final VoidCallback showBanner;
  final String url;
  ImageScreen({
    this.url,
    this.showBanner,
  });

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  ScreenshotController screenshotController = ScreenshotController();
  bool _isLoading = false, _isSavedToGallery = false;

  //for setting wallpaper
  Stream<String> progressString;
  String res;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
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
                          offset: Offset(0, -_controller.value * 100),
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
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      widget.showBanner();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        height: 64.0,
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: FlatButton(
                                          child: Text('Set as wallpaper'),
                                          onPressed: _showWallpaperDialog,
                                        ),
                                      ),
                                      customPopUpMenu(),
                                    ],
                                  ),
                                ],
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
                                  blurRadius: 2.0,
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
                  _showProgressDialog(),
                ],
              );
            },
          ),
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

  Future<bool> _onWillPop() async {
    widget.showBanner();
    return true;
  }

  void _showWallpaperDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Set a wallpaper',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Home Screen',
                  style: TextStyle(color: Colors.black),
                ),
                leading: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
                onTap: () => _setWallpaper(1),
              ),
              ListTile(
                title: Text(
                  'Lock Screen',
                  style: TextStyle(color: Colors.black),
                ),
                leading: Icon(
                  Icons.lock,
                  color: Colors.black,
                ),
                onTap: () => _setWallpaper(2),
              ),
              ListTile(
                title: Text(
                  'Both',
                  style: TextStyle(color: Colors.black),
                ),
                leading: Icon(
                  Icons.phone_android,
                  color: Colors.black,
                ),
                onTap: () => _setWallpaper(3),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setWallpaper(int wallpaperType) async {
    Navigator.pop(context, false);
    progressString = SetWallpaper.imageDownloadProgress(widget.url);
    progressString.listen((data) {
      setState(() {
        res = data;
        downloading = true;
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      switch (wallpaperType) {
        case 1: //home screen
          await SetWallpaper.homeScreen();
          break;
        case 2: //lock screen
          await SetWallpaper.lockScreen();
          break;
        case 3: //both
          await SetWallpaper.bothScreen();
          break;
      }
      setState(() {
        downloading = false;
      });
      _showToast('Wallpaper set successfully');
      print("Task Done");
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      _showToast('Error');
      print("Some Error");
    });
  }

  Widget _showProgressDialog() {
    return Positioned.fill(
      child: Center(
        child: downloading
            ? Container(
                height: 120.0,
                width: 200.0,
                child: Card(
                  color: Color(0xff323639),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 20.0),
                      Text(
                        "Downloading File : $res",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }

  _showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}
