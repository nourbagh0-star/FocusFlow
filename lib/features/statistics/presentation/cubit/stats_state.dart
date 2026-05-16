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
    List<DailyStats>? weekDays,
  })  : today = today ?? DailyStats.empty(DateTime(2000)),
        thisWeek = thisWeek ?? DailyStats.empty(DateTime(2000)),
        allTime = allTime ?? DailyStats.empty(DateTime(2000)),
        streak = streak ?? Streak.empty(),
        weekDays = weekDays ?? List.generate(7, (i) => DailyStats.empty(DateTime(2000)));

  final bool isLoading;
  final DailyStats today;
  final DailyStats thisWeek;
  final DailyStats allTime;
  final Streak streak;
  final List<DailyStats> weekDays;

  StatsState copyWith({
    bool? isLoading,
    DailyStats? today,
    DailyStats? thisWeek,
    DailyStats? allTime,
    Streak? streak,
    List<DailyStats>? weekDays,
  }) =>
      StatsState(
        isLoading: isLoading ?? this.isLoading,
        today: today ?? this.today,
        thisWeek: thisWeek ?? this.thisWeek,
        allTime: allTime ?? this.allTime,
        streak: streak ?? this.streak,
        weekDays: weekDays ?? this.weekDays,
      );

  @override
  List<Object?> get props => [isLoading, today, thisWeek, allTime, streak, weekDays];
}
