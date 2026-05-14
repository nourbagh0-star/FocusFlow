import 'package:focus_flow/features/statistics/domain/entities/streak.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';

class WatchStreak {
  const WatchStreak(this._repository);

  final StatsRepository _repository;

  Stream<Streak> call() => _repository.watchStreak();
}
