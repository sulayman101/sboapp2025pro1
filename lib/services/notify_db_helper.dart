import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../app_model/notification_model.dart';

class ManageNotifyProvider extends ChangeNotifier {
  final Box<NotificationModel> _notificationsBox =
      Hive.box<NotificationModel>('notifications');

  List<NotificationModel> get notifications =>
      _notificationsBox.values.toList();

  // Add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    await _notificationsBox.put(notification.id, notification);
    notifyListeners();
  }

  // Mark a notification as read
  Future<void> markAsRead(String id) async {
    final notification = _notificationsBox.get(id);
    if (notification != null) {
      notification.isRead = true;
      await _notificationsBox.put(id, notification);
      notifyListeners();
    }
  }

  // Delete a specific notification
  Future<void> deleteNotification(String id) async {
    await _notificationsBox.delete(id);
    notifyListeners();
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    await _notificationsBox.clear();
    notifyListeners();
  }
}
