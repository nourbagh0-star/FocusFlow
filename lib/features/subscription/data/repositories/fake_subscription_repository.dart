import 'dart:async';

import 'package:focus_flow/core/constants/product_ids.dart';
import 'package:focus_flow/features/subscription/domain/entities/product.dart';
import 'package:focus_flow/features/subscription/domain/entities/purchase_event.dart';
import 'package:focus_flow/features/subscription/domain/entities/subscription_period.dart';
import 'package:focus_flow/features/subscription/domain/entities/subscription_status.dart';
import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';

/// Day-8 stand-in for the real `in_app_purchase`-backed repository.
///
/// Replaced on Day 9 once Play Billing plumbing exists. Use [setProForDev]
/// from the Settings dev tile to flip Pro on/off without a paywall.
class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({
    this.fakeLatency = const Duration(milliseconds: 300),
    this.fakePurchaseDelay = const Duration(seconds: 1),
  });

  final Duration fakeLatency;
  final Duration fakePurchaseDelay;

  final StreamController<SubscriptionStatus> _statusController =
      StreamController<SubscriptionStatus>.broadcast();
  final StreamController<PurchaseEvent> _eventController =
      StreamController<PurchaseEvent>.broadcast();

  SubscriptionStatus _status = SubscriptionStatus.free;

  static const List<Product> _mockProducts = [
    Product(
      id: ProductIds.monthly,
      title: 'Pro Monthly',
      description: 'Unlock every Pro feature, billed monthly.',
      price: r'$1.99',
      period: SubscriptionPeriod.monthly,
    ),
    Product(
      id: ProductIds.yearly,
      title: 'Pro Yearly',
      description: 'Unlock every Pro feature, billed yearly. Save 37%.',
      price: r'$14.99',
      period: SubscriptionPeriod.yearly,
    ),
  ];

  @override
  Future<List<Product>> getProducts() async {
    await Future<void>.delayed(fakeLatency);
    return _mockProducts;
  }

  @override
  Future<void> purchase(String productId) async {
    _eventController.add(const PurchasePending());
    await Future<void>.delayed(fakePurchaseDelay);

    if (!ProductIds.all.contains(productId)) {
      _eventController.add(const PurchaseError(message: 'Unknown product id'));
      return;
    }

    _setStatus(SubscriptionStatus.pro(
      productId: productId,
      expiresAt: DateTime.now().add(_periodFor(productId)),
    ));
    _eventController.add(PurchaseSuccess(productId: productId));
  }

  @override
  Future<void> restorePurchases() async {
    await Future<void>.delayed(fakeLatency);
    // Fake has no past purchases to replay; emit current status for consistency.
    _statusController.add(_status);
  }

  @override
  Stream<SubscriptionStatus> watchSubscriptionStatus() async* {
    yield _status;
    yield* _statusController.stream;
  }

  @override
  Stream<PurchaseEvent> watchPurchaseEvents() => _eventController.stream;

  // Dev-only escape hatch. Removed on Day 9.
  void setProForDev({required bool isPro}) {
    if (isPro) {
      _setStatus(SubscriptionStatus.pro(
        productId: ProductIds.monthly,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ));
    } else {
      _setStatus(SubscriptionStatus.free);
    }
  }

  void _setStatus(SubscriptionStatus status) {
    _status = status;
    _statusController.add(status);
  }

  Duration _periodFor(String productId) {
    if (productId == ProductIds.yearly) return const Duration(days: 365);
    return const Duration(days: 30);
  }

  Future<void> dispose() async {
    await _statusController.close();
    await _eventController.close();
  }
}
