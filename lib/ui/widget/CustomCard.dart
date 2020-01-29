import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final String url;
  CustomCard({
    @required this.url,
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
      child: Container(
        child: (widget.url != null)
            ? CachedNetworkImage(
                imageUrl: widget.url,
                fit: BoxFit.cover,
              )
            : SizedBox.shrink(),
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
