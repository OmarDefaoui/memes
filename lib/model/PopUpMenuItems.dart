import 'package:flutter/material.dart';

class PopUpMenuItems {
  const PopUpMenuItems({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<PopUpMenuItems> popUpMenuItems = const <PopUpMenuItems>[
  const PopUpMenuItems(title: 'More apps', icon: Icons.more),
  const PopUpMenuItems(title: 'Share', icon: Icons.share),
  const PopUpMenuItems(title: 'Rate', icon: Icons.rate_review),
  const PopUpMenuItems(
      title: 'Privacy policy', icon: Icons.perm_device_information),
];
