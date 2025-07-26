import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buttomBarWidget(
    {required Color backgroundColor,
    required onTap,
    required int bottomNavIndex}) {
  final iconList = <IconData>[Icons.home, CupertinoIcons.book_fill];
  return AnimatedBottomNavigationBar(
    backgroundColor: backgroundColor,
    activeColor: Colors.white,
    leftCornerRadius: 20,
    rightCornerRadius: 20,
    gapLocation: GapLocation.none,
    icons: iconList,
    activeIndex: bottomNavIndex,
    onTap: onTap,
  );
}
