import 'package:intl/intl.dart';

String getExpirationDate({required int months}) {
  final currentDate = DateTime.now();
  final expirationDate = DateTime(
    currentDate.year,
    currentDate.month + months,
    currentDate.day,
  ).subtract(const Duration(days: 1)); // Adjust to the last day of the month
  return DateFormat('yyyy-MM-dd').format(expirationDate);
}
