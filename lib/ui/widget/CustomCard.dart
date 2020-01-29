import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final String url;
  final int index, memeIndex;
  CustomCard({
    @required this.url,
    this.index,
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
        borderRadius: BorderRadius.circular(4.0),
      ),
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
          Positioned.fill(
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Text(
                '${widget.index}: ${widget.memeIndex}',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    BoxShadow(
                      blurRadius: 25,
                      color: Colors.black,
                      offset: Offset(0.2, 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
