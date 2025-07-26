import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  //ConnectivityResult _connectionStatus = ConnectivityResult.mobile;
  List<ConnectivityResult> _connectionStatus = [];
  final Connectivity _connectivity = Connectivity();
  ConnectivityProvider() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _checkConnectivity();
  }

  List<ConnectivityResult> get connectionStatus => _connectionStatus;

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      log(result.toString());
      _updateConnectionStatus(result);
    } catch (e) {
      log(e.toString());
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    _connectionStatus = result;
    notifyListeners();
  }
}
