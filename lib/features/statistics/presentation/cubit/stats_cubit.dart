import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/features/statistics/domain/usecases/get_all_time_stats.dart';
import 'package:focus_flow/features/statistics/domain/usecases/get_week_daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/usecases/get_week_stats.dart';
import 'package:focus_flow/features/statistics/domain/usecases/watch_streak.dart';
import 'package:focus_flow/features/statistics/domain/usecases/watch_today_stats.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit({
    required this.watchTodayStats,
    required this.getWeekStats,
    required this.getAllTimeStats,
    required this.watchStreak,
    required this.getWeekDailyStats,
  }) : super(StatsState()) {
    _init();
  }

  final WatchTodayStats watchTodayStats;
  final GetWeekStats getWeekStats;
  final GetAllTimeStats getAllTimeStats;
  final WatchStreak watchStreak;
  final GetWeekDailyStats getWeekDailyStats;

  StreamSubscription? _todaySub;
  StreamSubscription? _streakSub;

  Future<void> _init() async {
    final today = await watchTodayStats().first;
    final streak = await watchStreak().first;
    final week = await getWeekStats();
    final allTime = await getAllTimeStats();
    final days = await getWeekDailyStats();

    if (isClosed) return;
    emit(StatsState(
      isLoading: false,
      today: today,
      thisWeek: week,
      allTime: allTime,
      streak: streak,
      weekDays: days,
    ));

    _todaySub = watchTodayStats().listen((today) {
      emit(state.copyWith(today: today));
      _reloadRange();
    });
    _streakSub = watchStreak().listen((streak) {
      emit(state.copyWith(streak: streak));
    });
  }

  Future<void> _reloadRange() async {
    final week = await getWeekStats();
    final allTime = await getAllTimeStats();
    final days = await getWeekDailyStats();
    if (!isClosed) emit(state.copyWith(thisWeek: week, allTime: allTime, weekDays: days));
  }

  @override
  Future<void> close() {
    _todaySub?.cancel();
    _streakSub?.cancel();
    return super.close();
  }
}
