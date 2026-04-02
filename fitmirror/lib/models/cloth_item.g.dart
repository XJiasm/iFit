// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloth_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothItemAdapter extends TypeAdapter<ClothItem> {
  @override
  final int typeId = 1;

  @override
  ClothItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClothItem(
      id: fields[0] as String,
      type: ClothType.values[fields[1] as int],
      originalPath: fields[2] as String,
      croppedPath: fields[3] as String,
      productUrl: fields[4] as String?,
      sourcePlatform: fields[5] as String?,
      color: fields[6] as String,
      styleTags: (fields[7] as List).cast<String>(),
      status: ClothStatus.values[fields[8] as int],
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ClothItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type.index)
      ..writeByte(2)
      ..write(obj.originalPath)
      ..writeByte(3)
      ..write(obj.croppedPath)
      ..writeByte(4)
      ..write(obj.productUrl)
      ..writeByte(5)
      ..write(obj.sourcePlatform)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.styleTags)
      ..writeByte(8)
      ..write(obj.status.index)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
