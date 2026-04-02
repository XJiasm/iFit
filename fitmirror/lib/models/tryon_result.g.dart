// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tryon_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TryOnResultAdapter extends TypeAdapter<TryOnResult> {
  @override
  final int typeId = 2;

  @override
  TryOnResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TryOnResult(
      id: fields[0] as String,
      avatarId: fields[1] as String,
      clothItemId: fields[2] as String,
      resultImagePath: fields[3] as String,
      offsetX: fields[4] as double,
      offsetY: fields[5] as double,
      scale: fields[6] as double,
      rotation: fields[7] as double,
      opacity: fields[8] as double,
      aiScore: fields[9] as int?,
      aiComment: fields[10] as String?,
      aiDetails: fields[11] as Map<String, dynamic>?,
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TryOnResult obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.avatarId)
      ..writeByte(2)
      ..write(obj.clothItemId)
      ..writeByte(3)
      ..write(obj.resultImagePath)
      ..writeByte(4)
      ..write(obj.offsetX)
      ..writeByte(5)
      ..write(obj.offsetY)
      ..writeByte(6)
      ..write(obj.scale)
      ..writeByte(7)
      ..write(obj.rotation)
      ..writeByte(8)
      ..write(obj.opacity)
      ..writeByte(9)
      ..write(obj.aiScore)
      ..writeByte(10)
      ..write(obj.aiComment)
      ..writeByte(11)
      ..write(obj.aiDetails)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TryOnResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
