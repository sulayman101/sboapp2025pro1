import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget bottomBarWidget({
  required Color backgroundColor,
  required void Function(int) onTap,
  required int bottomNavIndex,
}) {
  final List<IconData> iconList = [Icons.home, CupertinoIcons.book_fill];

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
