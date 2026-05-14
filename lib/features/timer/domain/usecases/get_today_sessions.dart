import 'package:focus_flow/core/utils/date_helpers.dart';
import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';

class GetTodaySessions {
  const GetTodaySessions(this._repository);

  final SessionRepository _repository;

  Future<List<PomodoroSession>> call() {
    final now = DateTime.now();
    return _repository.getInRange(startOfDay(now), endOfDay(now));
  }
}
