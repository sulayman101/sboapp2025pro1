import 'package:flutter/material.dart';

Widget subChecker({String? snapSubName, bool? snapSubActive}) {
  const subscriptionImages = {
    "Weekly": "assets/images/proImg/weekly.png",
    "Monthly": "assets/images/proImg/monthly.png",
    "Yearly": "assets/images/proImg/yearly.png",
  };

  final imagePath = snapSubActive == true
      ? subscriptionImages[snapSubName] ?? "assets/images/proImg/none.png"
      : "assets/images/proImg/none.png";

  return Image.asset(imagePath);
}
