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
      (fields[0] as List).cast<String>(),
      fields[1] as int?,
      fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryBatchDraft obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.crateIds)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.addressId);
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
