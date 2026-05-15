import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/entities/streak.dart';

abstract class StatsRepository {
  Future<DailyStats> getStatsForDay(DateTime day);

  Future<DailyStats> getStatsForRange(DateTime start, DateTime end);

  Stream<DailyStats> watchToday();

  Future<Streak> getStreak();

  Stream<Streak> watchStreak();
}
