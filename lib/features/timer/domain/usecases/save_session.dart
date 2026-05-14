import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';

class SaveSession {
  const SaveSession(this._repository);

  final SessionRepository _repository;

  Future<void> call(PomodoroSession session) => _repository.save(session);
}
