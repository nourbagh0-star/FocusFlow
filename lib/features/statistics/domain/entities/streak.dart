import 'package:equatable/equatable.dart';

class Streak extends Equatable {
  const Streak({
    required this.current,
    required this.longest,
    this.lastCompletedDate,
  });

  factory Streak.empty() => const Streak(current: 0, longest: 0);

  final int current;
  final int longest;
  final DateTime? lastCompletedDate;

  @override
  List<Object?> get props => [current, longest, lastCompletedDate];
}
