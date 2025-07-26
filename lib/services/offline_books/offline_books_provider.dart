import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sboapp/app_model/offline_books_model.dart';



class OfflineBooksProvider extends ChangeNotifier {
  final Box<OfflineBooksModel> _offlineBooksBox = Hive.box<OfflineBooksModel>('offline_data');
  List<OfflineBooksModel> get offlineBooks => _offlineBooksBox.values.toList();

  String? _isExist;
   String?  get  result => _isExist;

  // Add a book
  Future<void> addBook(OfflineBooksModel book, ) async {
    if(_offlineBooksBox.containsKey(book.bookId)) {
      _isExist = 'Exists';
      notifyListeners();
    }
    _isExist = 'successfully';
    await _offlineBooksBox.put(book.bookId, book);
    notifyListeners();
  }

  // Delete a book
  Future<void> deleteBook(String bookKey) async {
    await _offlineBooksBox.delete(bookKey);
    notifyListeners();
  }

  // Delete All book
  Future<void> deleteAllBook() async {
    _offlineBooksBox.deleteAll;
    await _offlineBooksBox.clear();
    notifyListeners();
  }
}
