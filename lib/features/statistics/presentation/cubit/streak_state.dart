import 'package:equatable/equatable.dart';

import 'package:focus_flow/features/statistics/domain/entities/streak.dart';

class StreakState extends Equatable {
  const StreakState({required this.streak, this.isLoading = false});

  factory StreakState.initial() =>
      StreakState(streak: Streak.empty(), isLoading: true);

  final Streak streak;
  final bool isLoading;

  @override
  List<Object?> get props => [streak, isLoading];
}
