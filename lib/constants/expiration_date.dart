import 'package:intl/intl.dart';

String getExpirationDate({required int months}) {
  final currentDate = DateTime.now();
  final expirationDate = DateTime(
    currentDate.year,
    currentDate.month + months - 1,
    currentDate.day,
  );
  return DateFormat('yyyy-MM-dd').format(expirationDate);
}
