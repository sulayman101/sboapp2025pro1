// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_books_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineBooksModelAdapter extends TypeAdapter<OfflineBooksModel> {
  @override
  final int typeId = 1;

  @override
  OfflineBooksModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineBooksModel(
      bookId: fields[0] as String,
      book: fields[1] as String,
      bookPath: fields[3] as String,
      bookImg: fields[4] as String,
      author: fields[2] as String,
      bookDate: fields[5] as String,
      bookLang: fields[6] as String,
      uid: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineBooksModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.bookId)
      ..writeByte(1)
      ..write(obj.book)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.bookPath)
      ..writeByte(4)
      ..write(obj.bookImg)
      ..writeByte(5)
      ..write(obj.bookDate)
      ..writeByte(6)
      ..write(obj.bookLang)
      ..writeByte(7)
      ..write(obj.uid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineBooksModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
