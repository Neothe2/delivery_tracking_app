// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CrateAdapter extends TypeAdapter<Crate> {
  @override
  final int typeId = 2;

  @override
  Crate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Crate(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Crate obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.crateId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
