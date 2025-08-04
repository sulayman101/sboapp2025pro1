import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sboapp/app_model/offline_books_model.dart';

class OfflineBooksProvider extends ChangeNotifier {
  final Box<OfflineBooksModel> _offlineBooksBox =
      Hive.box<OfflineBooksModel>('offline_data');

  List<OfflineBooksModel> get offlineBooks => _offlineBooksBox.values.toList();
  String? _operationResult;

  String? get operationResult => _operationResult;

  // Add a book
  Future<void> addBook(OfflineBooksModel book) async {
    if (_offlineBooksBox.containsKey(book.bookId)) {
      _operationResult = 'Book already exists';
    } else {
      await _offlineBooksBox.put(book.bookId, book);
      _operationResult = 'Book added successfully';
    }
    notifyListeners();
  }

  // Delete a book
  Future<void> deleteBook(String bookKey) async {
    await _offlineBooksBox.delete(bookKey);
    _operationResult = 'Book deleted successfully';
    notifyListeners();
  }

  // Delete all books
  Future<void> deleteAllBooks() async {
    await _offlineBooksBox.clear();
    _operationResult = 'All books deleted successfully';
    notifyListeners();
  }
}
