import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/usecases/watch_today_stats.dart';
import 'today_stats_state.dart';

class TodayStatsCubit extends Cubit<TodayStatsState> {
  TodayStatsCubit({required WatchTodayStats watchTodayStats})
      : _watch = watchTodayStats,
        super(const TodayStatsLoading()) {
    _sub = _watch().listen(
      (DailyStats stats) => emit(TodayStatsLoaded(stats)),
      onError: (Object e) => emit(TodayStatsError(e.toString())),
    );
  }

  final WatchTodayStats _watch;
  StreamSubscription<DailyStats>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
