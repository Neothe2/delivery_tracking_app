// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_scanning_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoadingScanningProgressAdapter
    extends TypeAdapter<LoadingScanningProgress> {
  @override
  final int typeId = 5;

  @override
  LoadingScanningProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoadingScanningProgress(
      crates: (fields[0] as List).cast<Crate>(),
    );
  }

  @override
  void write(BinaryWriter writer, LoadingScanningProgress obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.crates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingScanningProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
