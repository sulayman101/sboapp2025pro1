import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class InAppPurchaseNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get purchases => _purchases;
  bool get isLoading => _isLoading;

  static const String _accessToken = "AIzaSyA29xa8k8esOhRcJwHJWP6nvmpUHZ-obEQ";
  static const String _packageName = "com.dsd.sboapp";
  static const String _baseUrl =
      'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$_packageName/inappproducts';

  Future<void> fetchPurchases() async {
    _setLoadingState(true);

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _buildHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _purchases = List<Map<String, dynamic>>.from(data['inappproducts']);
      } else {
        log('Failed to load purchases: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching purchases: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> addPurchase({
    required String sku,
    required String title,
    required int priceMicros,
  }) async {
    final requestBody = {
      'sku': sku,
      'status': 'active',
      'defaultPrice': {
        'priceMicros': priceMicros.toString(),
        'currency': "USD",
      },
      'listings': {
        'en-US': {
          'title': title,
        },
      },
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _buildHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        log('Purchase added successfully');
        await fetchPurchases(); // Refresh the list
      } else {
        log('Failed to add purchase: ${response.statusCode}');
      }
    } catch (e) {
      log('Error adding purchase: $e');
    }
  }

  Map<String, dynamic>? getPurchaseDetailsForBook(String bookId) {
    return _purchases.firstWhere(
      (purchase) => purchase['sku'] == bookId,
    );
  }

  Map<String, String> _buildHeaders() {
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  void _setLoadingState(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
