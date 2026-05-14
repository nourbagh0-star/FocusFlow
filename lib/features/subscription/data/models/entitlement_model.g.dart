// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntitlementModelAdapter extends TypeAdapter<EntitlementModel> {
  @override
  final typeId = 1;

  @override
  EntitlementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntitlementModel(
      productId: fields[0] as String,
      purchasedAt: fields[1] as DateTime,
      expiresAt: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EntitlementModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.purchasedAt)
      ..writeByte(2)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntitlementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
