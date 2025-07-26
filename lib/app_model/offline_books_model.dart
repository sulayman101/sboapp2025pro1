
import 'package:hive/hive.dart';

part 'offline_books_model.g.dart'; // This file will be generated

@HiveType(typeId: 1) // Assign a unique typeId
class OfflineBooksModel {
  @HiveField(0)
  final String bookId;

  @HiveField(1)
  final String book;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String bookPath;

  @HiveField(4)
  final String bookImg;

  @HiveField(5)
  final String bookDate;

  @HiveField(6)
  final String bookLang;

  @HiveField(7)
  final String uid;

  OfflineBooksModel({
    required this.bookId,
    required this.book,
    required this.bookPath,
    required this.bookImg,
    required this.author,
    required this.bookDate,
    required this.bookLang,
    required this.uid
  });
}

