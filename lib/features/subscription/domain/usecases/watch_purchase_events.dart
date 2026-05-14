import 'package:focus_flow/features/subscription/domain/entities/purchase_event.dart';
import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';

class WatchPurchaseEvents {
  const WatchPurchaseEvents(this._repository);

  final SubscriptionRepository _repository;

  Stream<PurchaseEvent> call() => _repository.watchPurchaseEvents();
}
