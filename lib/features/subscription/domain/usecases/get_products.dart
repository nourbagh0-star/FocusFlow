import 'package:focus_flow/features/subscription/domain/entities/product.dart';
import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final SubscriptionRepository _repository;

  Future<List<Product>> call() => _repository.getProducts();
}
