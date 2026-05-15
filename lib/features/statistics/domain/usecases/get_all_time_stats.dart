import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';

class GetAllTimeStats {
  GetAllTimeStats(this._repository);

  final StatsRepository _repository;

  Future<DailyStats> call() {
    final end = DateTime.now().add(const Duration(days: 1));
    return _repository.getStatsForRange(DateTime(2000), end);
  }
}
