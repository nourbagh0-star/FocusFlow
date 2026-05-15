import 'package:equatable/equatable.dart';

import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/entities/streak.dart';

class StatsState extends Equatable {
  StatsState({
    this.isLoading = true,
    DailyStats? today,
    DailyStats? thisWeek,
    DailyStats? allTime,
    Streak? streak,
  })  : today = today ?? DailyStats.empty(DateTime(2000)),
        thisWeek = thisWeek ?? DailyStats.empty(DateTime(2000)),
        allTime = allTime ?? DailyStats.empty(DateTime(2000)),
        streak = streak ?? Streak.empty();

  final bool isLoading;
  final DailyStats today;
  final DailyStats thisWeek;
  final DailyStats allTime;
  final Streak streak;

  StatsState copyWith({
    bool? isLoading,
    DailyStats? today,
    DailyStats? thisWeek,
    DailyStats? allTime,
    Streak? streak,
  }) =>
      StatsState(
        isLoading: isLoading ?? this.isLoading,
        today: today ?? this.today,
        thisWeek: thisWeek ?? this.thisWeek,
        allTime: allTime ?? this.allTime,
        streak: streak ?? this.streak,
      );

  @override
  List<Object?> get props => [isLoading, today, thisWeek, allTime, streak];
}
