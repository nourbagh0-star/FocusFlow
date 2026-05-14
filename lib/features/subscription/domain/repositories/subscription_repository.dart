import 'package:focus_flow/features/subscription/domain/entities/product.dart';
import 'package:focus_flow/features/subscription/domain/entities/purchase_event.dart';
import 'package:focus_flow/features/subscription/domain/entities/subscription_status.dart';

abstract class SubscriptionRepository {
  Future<List<Product>> getProducts();

  Future<void> purchase(String productId);

  Future<void> restorePurchases();

  Stream<SubscriptionStatus> watchSubscriptionStatus();

  Stream<PurchaseEvent> watchPurchaseEvents();
}
