import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';

class ExportSessionsCsv {
  const ExportSessionsCsv(this._repository);

  final SessionRepository _repository;

  Future<String> call() async {
    final sessions = await _repository.getInRange(
      DateTime(2000),
      DateTime.now().add(const Duration(days: 1)),
    );
    return _toCsv(sessions);
  }

  String _toCsv(List<PomodoroSession> sessions) {
    final buf = StringBuffer()
      ..writeln(
        'id,type,started_at,completed_at,planned_seconds,actual_seconds,completed',
      );
    for (final s in sessions) {
      buf.writeln([
        s.id,
        s.type.name,
        s.startedAt.toIso8601String(),
        s.completedAt.toIso8601String(),
        s.plannedDuration.inSeconds,
        s.actualDuration.inSeconds,
        s.completed,
      ].join(','));
    }
    return buf.toString();
  }
}
