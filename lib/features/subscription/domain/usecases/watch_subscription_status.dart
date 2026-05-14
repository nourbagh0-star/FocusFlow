import 'package:focus_flow/features/subscription/domain/entities/subscription_status.dart';
import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';

class WatchSubscriptionStatus {
  const WatchSubscriptionStatus(this._repository);

  final SubscriptionRepository _repository;

  Stream<SubscriptionStatus> call() => _repository.watchSubscriptionStatus();
}
