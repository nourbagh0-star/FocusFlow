import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';

class RestorePurchases {
  const RestorePurchases(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call() => _repository.restorePurchases();
}
