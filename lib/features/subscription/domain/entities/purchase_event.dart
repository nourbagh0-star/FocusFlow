import 'package:equatable/equatable.dart';

sealed class PurchaseEvent extends Equatable {
  const PurchaseEvent();
}

class PurchasePending extends PurchaseEvent {
  const PurchasePending();

  @override
  List<Object?> get props => [];
}

class PurchaseSuccess extends PurchaseEvent {
  const PurchaseSuccess({required this.productId});

  final String productId;

  @override
  List<Object?> get props => [productId];
}

class PurchaseCanceled extends PurchaseEvent {
  const PurchaseCanceled();

  @override
  List<Object?> get props => [];
}

class PurchaseError extends PurchaseEvent {
  const PurchaseError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
