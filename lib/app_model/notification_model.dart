

import 'package:hive/hive.dart';
part 'notification_model.g.dart';

@HiveType(typeId: 0)
class NotificationModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? imgUrl;

  @HiveField(2)
  String title;

  @HiveField(3)
  String subtitle;

  @HiveField(4)
  String? link;

  @HiveField(5)
  String? bookLink;

  @HiveField(6)
  String? date;

  @HiveField(7)
  bool isRead;

  @HiveField(8)
  String uid;

  NotificationModel({
    required this.id,
    this.imgUrl,
    required this.title,
    required this.subtitle,
    this.link,
    this.bookLink,
    this.date,
    required this.isRead,
    required this.uid,
  });
}


