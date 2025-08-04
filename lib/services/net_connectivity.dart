import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  ConnectivityProvider() {
    _initializeConnectivity();
  }

  ConnectivityResult get connectionStatus => _connectionStatus;

  Future<void> _initializeConnectivity() async {
    try {
      var connectivityResults = await _connectivity.checkConnectivity();
      _connectionStatus = connectivityResults.isNotEmpty
          ? connectivityResults.first
          : ConnectivityResult.none;
      _connectivity.onConnectivityChanged.listen((results) {
        if (results.isNotEmpty) {
          _updateConnectionStatus(results.first);
        }
      });
      notifyListeners();
    } catch (e) {
      log("Error initializing connectivity: $e");
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus = result;
    notifyListeners();
  }
}
