import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';

class PurchaseProduct {
  const PurchaseProduct(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(String productId) => _repository.purchase(productId);
}
