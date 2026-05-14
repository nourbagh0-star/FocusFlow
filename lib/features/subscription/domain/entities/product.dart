import 'package:equatable/equatable.dart';

import 'subscription_period.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
  });

  final String id;
  final String title;
  final String description;
  final String price;
  final SubscriptionPeriod period;

  @override
  List<Object?> get props => [id, title, description, price, period];
}
