import 'package:hive_ce/hive.dart';

part 'entitlement_model.g.dart';

@HiveType(typeId: 1)
class EntitlementModel {
  EntitlementModel({
    required this.productId,
    required this.purchasedAt,
    this.expiresAt,
  });

  @HiveField(0)
  final String productId;

  @HiveField(1)
  final DateTime purchasedAt;

  @HiveField(2)
  final DateTime? expiresAt;
}
