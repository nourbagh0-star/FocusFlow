import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';

class WatchTodayStats {
  const WatchTodayStats(this._repository);

  final StatsRepository _repository;

  Stream<DailyStats> call() => _repository.watchToday();
}
