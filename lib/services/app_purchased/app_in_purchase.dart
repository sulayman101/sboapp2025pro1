

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class InAppPurchaseNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get purchases => _purchases;
  bool get isLoading => _isLoading;

  Future<void> fetchPurchases() async {
    _isLoading = true;
    notifyListeners();

    String accessToken = "AIzaSyA29xa8k8esOhRcJwHJWP6nvmpUHZ-obEQ";
    String packageName = "com.dsd.sboapp";
    final url = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$packageName/inappproducts';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _purchases = List<Map<String, dynamic>>.from(data['inappproducts']);
    } else {
      // Handle error
      log('Failed to load purchases');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPurchase(
      String sku,
      String title,
      int priceMicros,
      ) async {
    String packageName = "com.dsd.sboapp";
    final url = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$packageName/inappproducts';
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

    String accessToken = "AIzaSyA29xa8k8esOhRcJwHJWP6nvmpUHZ-obEQ";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      // Handle successful addition
      log('Purchase added successfully');
      await fetchPurchases(); // Refresh the list
    } else {
      // Handle error
      log('Failed to add purchase');
    }
  }

  Map<String, dynamic>? getPurchaseDetailsForBook(String bookId) {
    return _purchases.firstWhere(
          (purchase) => purchase['sku'] == bookId,
      //orElse: () => null,
    );
  }
}


/**
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';



class InAppPurchaseNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = false;


  List<Map<String, dynamic>> get purchases => _purchases;
  bool get isLoading => _isLoading;


  Future<void> fetchPurchases() async {
    _isLoading = true;
    notifyListeners();

    String accessToken = "YOUR_ACCESS_TOKEN";
    String packageName = "com.dsd.sboapp";
    final url = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$packageName/inappproducts';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _purchases = List<Map<String, dynamic>>.from(data['inappproducts']);
    } else {
      // Handle error
      log('Failed to load purchases');
    }

    _isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic>? getPurchaseDetailsForBook(String bookId) {
    return _purchases.firstWhere(
          (purchase) => purchase['productId'] == bookId,
      orElse: () => null,
    );
  }


  Future<void> addPurchase(
      String sku,
      String title,
      //String description,
      int priceMicros,
      ) async {
    String packageName = "com.dsd.sboapp";
    final url = 'https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$packageName/inappproducts';
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
          //'description': description,
        },
      },
    };

    String accessToken = "AIzaSyA29xa8k8esOhRcJwHJWP6nvmpUHZ-obEQ";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      // Handle successful addition
      print('Purchase added successfully');
      await fetchPurchases(); // Refresh the list
    } else {
      // Handle error
      log('Failed to add purchase');
    }
  }



}
    **/