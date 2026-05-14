import 'package:equatable/equatable.dart';

import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';

sealed class TodayStatsState extends Equatable {
  const TodayStatsState();
}

class TodayStatsLoading extends TodayStatsState {
  const TodayStatsLoading();

  @override
  List<Object?> get props => [];
}

class TodayStatsLoaded extends TodayStatsState {
  const TodayStatsLoaded(this.stats);

  final DailyStats stats;

  @override
  List<Object?> get props => [stats];
}

class TodayStatsError extends TodayStatsState {
  const TodayStatsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
