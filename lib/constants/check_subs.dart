import 'package:flutter/material.dart';

Widget subChecker({String? snapSubName, bool? snapSubActive}) {
  String subMonthly = "Monthly";
  String subWeekly = "Weekly";
  String subYearly = "Yearly";
  if (snapSubName == subWeekly && snapSubActive == true) {
    return Image.asset("assets/images/proImg/weekly.png");
  }
  if (snapSubName == subMonthly && snapSubActive == true) {
    return Image.asset("assets/images/proImg/monthly.png");
  }
  if (snapSubName == subYearly && snapSubActive == true) {
    return Image.asset("assets/images/proImg/yearly.png");
  } else {
    return Image.asset("assets/images/proImg/none.png");
  }
}
