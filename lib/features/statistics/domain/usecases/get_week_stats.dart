import 'package:focus_flow/core/utils/date_helpers.dart';
import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';

class GetWeekStats {
  GetWeekStats(this._repository);

  final StatsRepository _repository;

  Future<DailyStats> call() {
    final now = DateTime.now();
    final monday = startOfDay(now.subtract(Duration(days: now.weekday - 1)));
    return _repository.getStatsForRange(monday, endOfDay(now));
  }
}
