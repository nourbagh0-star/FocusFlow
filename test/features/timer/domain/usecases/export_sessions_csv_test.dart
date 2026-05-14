import 'package:flutter_test/flutter_test.dart';

import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';
import 'package:focus_flow/features/timer/domain/usecases/export_sessions_csv.dart';

class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository(this.sessions);

  final List<PomodoroSession> sessions;

  @override
  Future<void> save(PomodoroSession session) async => sessions.add(session);

  @override
  Future<List<PomodoroSession>> getInRange(DateTime start, DateTime end) async {
    return sessions
        .where((s) =>
            !s.completedAt.isBefore(start) && s.completedAt.isBefore(end))
        .toList();
  }

  @override
  Stream<void> watchChanges() => const Stream.empty();
}

void main() {
  group('ExportSessionsCsv', () {
    test('produces header even when no sessions exist', () async {
      final useCase = ExportSessionsCsv(FakeSessionRepository([]));
      final csv = await useCase();
      expect(csv.trim(),
          'id,type,started_at,completed_at,planned_seconds,actual_seconds,completed');
    });

    test('writes one row per session with the right fields', () async {
      final session = PomodoroSession(
        id: 'sess-1',
        type: SessionType.work,
        startedAt: DateTime.utc(2026, 5, 1, 9),
        completedAt: DateTime.utc(2026, 5, 1, 9, 25),
        plannedDuration: const Duration(minutes: 25),
        actualDuration: const Duration(minutes: 25),
        completed: true,
      );
      final useCase = ExportSessionsCsv(FakeSessionRepository([session]));
      final csv = await useCase();
      final lines = csv.trim().split('\n');
      expect(lines, hasLength(2));
      expect(lines.first.startsWith('id,type'), isTrue);
      expect(lines.last, contains('sess-1'));
      expect(lines.last, contains('work'));
      expect(lines.last, contains('1500')); // 25 minutes in seconds
      expect(lines.last, endsWith('true'));
    });
  });
}
