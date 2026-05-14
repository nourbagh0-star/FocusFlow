import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';

abstract class SessionRepository {
  Future<void> save(PomodoroSession session);

  Future<List<PomodoroSession>> getInRange(DateTime start, DateTime end);

  Stream<void> watchChanges();
}
