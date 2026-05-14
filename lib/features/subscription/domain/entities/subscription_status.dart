import 'package:equatable/equatable.dart';

class SubscriptionStatus extends Equatable {
  const SubscriptionStatus({
    required this.isPro,
    this.activeProductId,
    this.expiresAt,
  });

  static const SubscriptionStatus free = SubscriptionStatus(isPro: false);

  factory SubscriptionStatus.pro({
    required String productId,
    DateTime? expiresAt,
  }) =>
      SubscriptionStatus(
        isPro: true,
        activeProductId: productId,
        expiresAt: expiresAt,
      );

  final bool isPro;
  final String? activeProductId;
  final DateTime? expiresAt;

  @override
  List<Object?> get props => [isPro, activeProductId, expiresAt];
}
