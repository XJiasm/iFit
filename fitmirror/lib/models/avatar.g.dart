// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AvatarAdapter extends TypeAdapter<Avatar> {
  @override
  final int typeId = 0;

  @override
  Avatar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Avatar(
      id: fields[0] as String,
      name: fields[1] as String,
      photoPath: fields[2] as String,
      thumbnailPath: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Avatar obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.photoPath)
      ..writeByte(3)
      ..write(obj.thumbnailPath)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
