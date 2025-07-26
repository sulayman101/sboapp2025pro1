// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 0;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String,
      imgUrl: fields[1] as String?,
      title: fields[2] as String,
      subtitle: fields[3] as String,
      link: fields[4] as String?,
      bookLink: fields[5] as String?,
      date: fields[6] as String?,
      isRead: fields[7] as bool,
      uid: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imgUrl)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.link)
      ..writeByte(5)
      ..write(obj.bookLink)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.isRead)
      ..writeByte(8)
      ..write(obj.uid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
