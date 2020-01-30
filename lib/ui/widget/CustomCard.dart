import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final String url;
  final int memeIndex;
  CustomCard({
    @required this.url,
    this.memeIndex,
  });

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: Stack(
        children: <Widget>[
          Container(
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.cover,
            ),
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}
