// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_batch_draft.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryBatchDraftAdapter extends TypeAdapter<DeliveryBatchDraft> {
  @override
  final int typeId = 1;

  @override
  DeliveryBatchDraft read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryBatchDraft(
      (fields[0] as List).cast<Crate>(),
      fields[1] as Customer?,
      fields[2] as Address?,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryBatchDraft obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.crates)
      ..writeByte(1)
      ..write(obj.customer)
      ..writeByte(2)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryBatchDraftAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
