import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/features/subscription/domain/entities/purchase_event.dart';
import 'package:focus_flow/features/subscription/domain/entities/subscription_status.dart';
import 'package:focus_flow/features/subscription/domain/usecases/get_products.dart';
import 'package:focus_flow/features/subscription/domain/usecases/purchase_product.dart';
import 'package:focus_flow/features/subscription/domain/usecases/restore_purchases.dart';
import 'package:focus_flow/features/subscription/domain/usecases/watch_purchase_events.dart';
import 'package:focus_flow/features/subscription/domain/usecases/watch_subscription_status.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required GetProducts getProducts,
    required PurchaseProduct purchaseProduct,
    required RestorePurchases restorePurchases,
    required WatchSubscriptionStatus watchSubscriptionStatus,
    required WatchPurchaseEvents watchPurchaseEvents,
  })  : _getProducts = getProducts,
        _purchaseProduct = purchaseProduct,
        _restorePurchases = restorePurchases,
        super(SubscriptionState.initial()) {
    _statusSub = watchSubscriptionStatus().listen(_onStatus);
    _eventSub = watchPurchaseEvents().listen(_onEvent);
  }

  final GetProducts _getProducts;
  final PurchaseProduct _purchaseProduct;
  final RestorePurchases _restorePurchases;

  StreamSubscription<SubscriptionStatus>? _statusSub;
  StreamSubscription<PurchaseEvent>? _eventSub;

  Future<void> loadProducts() async {
    emit(state.copyWith(isLoadingProducts: true, clearLastError: true));
    try {
      final products = await _getProducts();
      if (isClosed) return;
      emit(state.copyWith(products: products, isLoadingProducts: false));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingProducts: false,
        lastError: 'Could not load products: $e',
      ));
    }
  }

  Future<void> purchase(String productId) async {
    emit(state.copyWith(isProcessingPurchase: true, clearLastError: true));
    try {
      await _purchaseProduct(productId);
      // Purchase result arrives via the events stream; flag flipped off in _onEvent.
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isProcessingPurchase: false,
        lastError: 'Purchase failed: $e',
      ));
    }
  }

  Future<void> restore() async {
    emit(state.copyWith(clearLastError: true));
    try {
      await _restorePurchases();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(lastError: 'Restore failed: $e'));
    }
  }

  void _onStatus(SubscriptionStatus status) {
    if (isClosed) return;
    emit(state.copyWith(status: status));
  }

  void _onEvent(PurchaseEvent event) {
    if (isClosed) return;
    switch (event) {
      case PurchasePending():
        break;
      case PurchaseSuccess():
        emit(state.copyWith(isProcessingPurchase: false));
      case PurchaseCanceled():
        emit(state.copyWith(isProcessingPurchase: false));
      case PurchaseError(:final message):
        emit(state.copyWith(
          isProcessingPurchase: false,
          lastError: message,
        ));
    }
  }

  @override
  Future<void> close() {
    _statusSub?.cancel();
    _eventSub?.cancel();
    return super.close();
  }
}
