// 1. CREATE NEW FILE: lib/services/app_update_manager.dart
import 'dart:async';
import 'dart:developer';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateManager {
  static AppUpdateManager? _instance;
  static AppUpdateManager get instance => _instance ??= AppUpdateManager._internal();

  AppUpdateManager._internal();

  AppUpdateInfo? _updateInfo;
  bool _isChecking = false;
  Timer? _updateCheckTimer;
  bool _initialized = false;

  /// Initialize the update manager - Call this once in main()
  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;
    log('AppUpdateManager initialized');

    // Check for updates once on app start
    await checkForUpdates();

    // Then check periodically (every 24 hours instead of constantly)
    startPeriodicUpdateCheck();
  }

  /// Check for updates (with proper error handling and rate limiting)
  Future<void> checkForUpdates() async {
    if (_isChecking) {
      log('Update check already in progress, skipping...');
      return;
    }

    _isChecking = true;

    try {
      log('Checking for app updates...');

      final appUpdateInfo = await InAppUpdate.checkForUpdate();
      _updateInfo = appUpdateInfo;

      if (appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        log('Update available: ${appUpdateInfo.availableVersionCode}');
        _handleUpdateAvailable(appUpdateInfo);
      } else {
        log('No updates available');
      }

    } catch (e) {
      log('Update check failed: $e');
      // Don't rethrow - just log the error to prevent crashes
    } finally {
      _isChecking = false;
    }
  }

  /// Handle when update is available
  void _handleUpdateAvailable(AppUpdateInfo updateInfo) {
    // You can implement your own update logic here
    // For example, show a dialog to user
    _showUpdateDialog(updateInfo);
  }

  /// Show update dialog (implement based on your UI framework)
  void _showUpdateDialog(AppUpdateInfo updateInfo) {
    // This is a placeholder - implement based on your app's navigation
    log('Should show update dialog to user');

    // Example implementation:
    /*
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text('Update Available'),
        content: Text('A new version is available. Would you like to update?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              performUpdate(updateInfo);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
    */
  }

  /// Perform the actual update
  Future<void> performUpdate(AppUpdateInfo updateInfo) async {
    try {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      log('Update failed: $e');
    }
  }

  /// Start periodic update checks (every 24 hours)
  void startPeriodicUpdateCheck() {
    _updateCheckTimer?.cancel();
    _updateCheckTimer = Timer.periodic(
      const Duration(hours: 24), // Check once per day instead of constantly
          (_) => checkForUpdates(),
    );
    log('Periodic update checks started (every 24 hours)');
  }

  /// Stop periodic update checks
  void stopPeriodicUpdateCheck() {
    _updateCheckTimer?.cancel();
    _updateCheckTimer = null;
    log('Periodic update checks stopped');
  }

  /// Get current update info
  AppUpdateInfo? get currentUpdateInfo => _updateInfo;

  /// Check if update check is in progress
  bool get isCheckingForUpdates => _isChecking;

  /// Dispose of resources
  void dispose() {
    _updateCheckTimer?.cancel();
    _updateCheckTimer = null;
    _isChecking = false;
    _initialized = false;
    log('AppUpdateManager disposed');
  }
}
