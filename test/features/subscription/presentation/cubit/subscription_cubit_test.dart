import 'package:flutter_test/flutter_test.dart';

import 'package:focus_flow/core/constants/product_ids.dart';
import 'package:focus_flow/features/subscription/data/repositories/fake_subscription_repository.dart';
import 'package:focus_flow/features/subscription/domain/usecases/get_products.dart';
import 'package:focus_flow/features/subscription/domain/usecases/purchase_product.dart';
import 'package:focus_flow/features/subscription/domain/usecases/restore_purchases.dart';
import 'package:focus_flow/features/subscription/domain/usecases/watch_purchase_events.dart';
import 'package:focus_flow/features/subscription/domain/usecases/watch_subscription_status.dart';
import 'package:focus_flow/features/subscription/presentation/cubit/subscription_cubit.dart';

SubscriptionCubit buildCubit(FakeSubscriptionRepository repo) {
  return SubscriptionCubit(
    getProducts: GetProducts(repo),
    purchaseProduct: PurchaseProduct(repo),
    restorePurchases: RestorePurchases(repo),
    watchSubscriptionStatus: WatchSubscriptionStatus(repo),
    watchPurchaseEvents: WatchPurchaseEvents(repo),
  );
}

FakeSubscriptionRepository fastRepo() => FakeSubscriptionRepository(
      fakeLatency: Duration.zero,
      fakePurchaseDelay: Duration.zero,
    );

Future<void> pumpEventLoop() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  group('SubscriptionCubit', () {
    test('initial state has isPro=false and no products', () {
      final repo = fastRepo();
      final cubit = buildCubit(repo);

      expect(cubit.state.status.isPro, false);
      expect(cubit.state.products, isEmpty);

      cubit.close();
      repo.dispose();
    });

    test('loadProducts populates products list', () async {
      final repo = fastRepo();
      final cubit = buildCubit(repo);

      await cubit.loadProducts();

      expect(cubit.state.products, hasLength(2));
      expect(cubit.state.isLoadingProducts, false);

      await cubit.close();
      await repo.dispose();
    });

    test('purchase flips isPro to true via the status stream', () async {
      final repo = fastRepo();
      final cubit = buildCubit(repo);

      await cubit.purchase(ProductIds.monthly);
      await pumpEventLoop();

      expect(cubit.state.status.isPro, true);
      expect(cubit.state.status.activeProductId, ProductIds.monthly);
      expect(cubit.state.isProcessingPurchase, false);

      await cubit.close();
      await repo.dispose();
    });

    test('purchase with unknown product id sets lastError', () async {
      final repo = fastRepo();
      final cubit = buildCubit(repo);

      await cubit.purchase('not_a_real_product');
      await pumpEventLoop();

      expect(cubit.state.status.isPro, false);
      expect(cubit.state.lastError, isNotNull);
      expect(cubit.state.isProcessingPurchase, false);

      await cubit.close();
      await repo.dispose();
    });

    test('setProForDev toggles isPro on then off', () async {
      final repo = fastRepo();
      final cubit = buildCubit(repo);
      await pumpEventLoop();

      repo.setProForDev(isPro: true);
      await pumpEventLoop();
      expect(cubit.state.status.isPro, true);

      repo.setProForDev(isPro: false);
      await pumpEventLoop();
      expect(cubit.state.status.isPro, false);

      await cubit.close();
      await repo.dispose();
    });
  });
}
