import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';

class GetTodayStats {
  const GetTodayStats(this._repository);

  final StatsRepository _repository;

  Future<DailyStats> call() => _repository.getStatsForDay(DateTime.now());
}
