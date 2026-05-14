import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:focus_flow/core/constants/product_ids.dart';
import 'package:focus_flow/features/subscription/data/datasources/entitlement_local_datasource.dart';
import 'package:focus_flow/features/subscription/data/models/entitlement_model.dart';
import 'package:focus_flow/features/subscription/domain/entities/product.dart';
import 'package:focus_flow/features/subscription/domain/entities/purchase_event.dart';
import 'package:focus_flow/features/subscription/domain/entities/subscription_period.dart';
import 'package:focus_flow/features/subscription/domain/entities/subscription_status.dart';
import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required InAppPurchase iap,
    required EntitlementLocalDataSource cache,
  })  : _iap = iap,
        _cache = cache {
    _purchaseStreamSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object _) {
        // Plugin-level errors are surfaced per-purchase via PurchaseDetails.error.
      },
    );

    // Seed status from cache for instant UI on launch.
    final cached = _cache.get();
    if (cached != null) {
      _status = SubscriptionStatus.pro(
        productId: cached.productId,
        expiresAt: cached.expiresAt,
      );
    }

    // Fire-and-forget restore to re-validate with Play Billing.
    unawaited(_iap.restorePurchases());
  }

  final InAppPurchase _iap;
  final EntitlementLocalDataSource _cache;
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSub;

  final StreamController<SubscriptionStatus> _statusController =
      StreamController<SubscriptionStatus>.broadcast();
  final StreamController<PurchaseEvent> _eventController =
      StreamController<PurchaseEvent>.broadcast();

  SubscriptionStatus _status = SubscriptionStatus.free;

  @override
  Future<List<Product>> getProducts() async {
    final response = await _iap.queryProductDetails(ProductIds.all.toSet());
    if (response.error != null) {
      throw Exception(response.error!.message);
    }
    return response.productDetails.map(_toProduct).toList();
  }

  @override
  Future<void> purchase(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) {
      _eventController.add(
        PurchaseError(message: 'Product not found: $productId'),
      );
      return;
    }
    final details = response.productDetails.first;
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
    // Result arrives via _onPurchaseUpdate from purchaseStream.
  }

  @override
  Future<void> restorePurchases() => _iap.restorePurchases();

  @override
  Stream<SubscriptionStatus> watchSubscriptionStatus() async* {
    yield _status;
    yield* _statusController.stream;
  }

  @override
  Stream<PurchaseEvent> watchPurchaseEvents() => _eventController.stream;

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _eventController.add(const PurchasePending());
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantEntitlement(p);
        case PurchaseStatus.canceled:
          _eventController.add(const PurchaseCanceled());
        case PurchaseStatus.error:
          _eventController.add(PurchaseError(
            message: p.error?.message ?? 'Unknown purchase error',
          ));
      }

      // CRITICAL: tell Google Play we handled this purchase. Otherwise
      // it gets auto-refunded within ~3 days.
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> _grantEntitlement(PurchaseDetails p) async {
    // PORTFOLIO LIMITATION: production apps verify p.verificationData here by
    // POSTing serverVerificationData to a backend that calls Google Play
    // Developer API. Client-only validation is forgeable.
    final purchasedAt = DateTime.now();
    final expiresAt = purchasedAt.add(_periodFor(p.productID));
    final entitlement = EntitlementModel(
      productId: p.productID,
      purchasedAt: purchasedAt,
      expiresAt: expiresAt,
    );
    await _cache.save(entitlement);

    _status = SubscriptionStatus.pro(
      productId: p.productID,
      expiresAt: expiresAt,
    );
    _statusController.add(_status);
    _eventController.add(PurchaseSuccess(productId: p.productID));
  }

  Duration _periodFor(String productId) {
    if (productId == ProductIds.yearly) return const Duration(days: 365);
    return const Duration(days: 30);
  }

  Product _toProduct(ProductDetails details) => Product(
        id: details.id,
        title: details.title,
        description: details.description,
        price: details.price,
        period: details.id == ProductIds.yearly
            ? SubscriptionPeriod.yearly
            : SubscriptionPeriod.monthly,
      );

  Future<void> dispose() async {
    await _purchaseStreamSub?.cancel();
    await _statusController.close();
    await _eventController.close();
  }
}
