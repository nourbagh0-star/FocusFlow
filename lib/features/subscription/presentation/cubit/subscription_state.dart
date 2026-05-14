import 'package:equatable/equatable.dart';

import 'package:focus_flow/features/subscription/domain/entities/product.dart';
import 'package:focus_flow/features/subscription/domain/entities/subscription_status.dart';

class SubscriptionState extends Equatable {
  const SubscriptionState({
    required this.status,
    this.products = const [],
    this.isLoadingProducts = false,
    this.isProcessingPurchase = false,
    this.lastError,
  });

  factory SubscriptionState.initial() =>
      const SubscriptionState(status: SubscriptionStatus.free);

  final SubscriptionStatus status;
  final List<Product> products;
  final bool isLoadingProducts;
  final bool isProcessingPurchase;
  final String? lastError;

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    List<Product>? products,
    bool? isLoadingProducts,
    bool? isProcessingPurchase,
    String? lastError,
    bool clearLastError = false,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      products: products ?? this.products,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isProcessingPurchase: isProcessingPurchase ?? this.isProcessingPurchase,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        isLoadingProducts,
        isProcessingPurchase,
        lastError,
      ];
}
