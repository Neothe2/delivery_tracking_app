// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unloading_scanning_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnloadingScanningProgressAdapter
    extends TypeAdapter<UnloadingScanningProgress> {
  @override
  final int typeId = 6;

  @override
  UnloadingScanningProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnloadingScanningProgress(
      crates: (fields[0] as List).cast<Crate>(),
      deliveryBatchId: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UnloadingScanningProgress obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.crates)
      ..writeByte(1)
      ..write(obj.deliveryBatchId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnloadingScanningProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
