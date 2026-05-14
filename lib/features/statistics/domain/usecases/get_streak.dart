import 'package:focus_flow/features/statistics/domain/entities/streak.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';

class GetStreak {
  const GetStreak(this._repository);

  final StatsRepository _repository;

  Future<Streak> call() => _repository.getStreak();
}
