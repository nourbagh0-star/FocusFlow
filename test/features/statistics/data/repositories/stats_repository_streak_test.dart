import 'package:flutter_test/flutter_test.dart';

import 'package:focus_flow/features/statistics/data/repositories/stats_repository_impl.dart';
import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';

class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository(this.sessions);

  final List<PomodoroSession> sessions;

  @override
  Future<void> save(PomodoroSession session) async {
    sessions.add(session);
  }

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

PomodoroSession workSession({required DateTime at, bool completed = true}) =>
    PomodoroSession(
      id: 's_${at.toIso8601String()}',
      type: SessionType.work,
      startedAt: at,
      completedAt: at,
      plannedDuration: const Duration(minutes: 25),
      actualDuration: const Duration(minutes: 25),
      completed: completed,
    );

void main() {
  group('StatsRepository — streak', () {
    test('empty sessions → 0 current, 0 longest', () async {
      final repo = StatsRepositoryImpl(
        sessionRepository: FakeSessionRepository([]),
      );
      final streak = await repo.getStreak();
      expect(streak.current, 0);
      expect(streak.longest, 0);
    });

    test('one work session today → 1/1', () async {
      final now = DateTime.now();
      final repo = StatsRepositoryImpl(
        sessionRepository: FakeSessionRepository([workSession(at: now)]),
      );
      final streak = await repo.getStreak();
      expect(streak.current, 1);
      expect(streak.longest, 1);
    });

    test('three consecutive days ending today → 3/3', () async {
      final now = DateTime.now();
      final repo = StatsRepositoryImpl(
        sessionRepository: FakeSessionRepository([
          workSession(at: now.subtract(const Duration(days: 2))),
          workSession(at: now.subtract(const Duration(days: 1))),
          workSession(at: now),
        ]),
      );
      final streak = await repo.getStreak();
      expect(streak.current, 3);
      expect(streak.longest, 3);
    });

    test('gap breaks current but preserves longest', () async {
      final now = DateTime.now();
      final repo = StatsRepositoryImpl(
        sessionRepository: FakeSessionRepository([
          workSession(at: now.subtract(const Duration(days: 10))),
          workSession(at: now.subtract(const Duration(days: 9))),
          workSession(at: now.subtract(const Duration(days: 8))),
          workSession(at: now),
        ]),
      );
      final streak = await repo.getStreak();
      expect(streak.current, 1);
      expect(streak.longest, 3);
    });

    test('yesterday-only still counts as current (grace day)', () async {
      final now = DateTime.now();
      final repo = StatsRepositoryImpl(
        sessionRepository: FakeSessionRepository([
          workSession(at: now.subtract(const Duration(days: 2))),
          workSession(at: now.subtract(const Duration(days: 1))),
        ]),
      );
      final streak = await repo.getStreak();
      expect(streak.current, 2);
    });

    test('incomplete sessions are ignored', () async {
      final now = DateTime.now();
      final repo = StatsRepositoryImpl(
        sessionRepository:
            FakeSessionRepository([workSession(at: now, completed: false)]),
      );
      final streak = await repo.getStreak();
      expect(streak.current, 0);
    });

    test('multiple sessions in a single day count as one day', () async {
      final now = DateTime.now();
      final earlier = DateTime(now.year, now.month, now.day, 9, 0);
      final later = DateTime(now.year, now.month, now.day, 14, 0);
      final repo = StatsRepositoryImpl(
        sessionRepository: FakeSessionRepository([
          workSession(at: earlier),
          workSession(at: later),
        ]),
      );
      final streak = await repo.getStreak();
      expect(streak.current, 1);
      expect(streak.longest, 1);
    });
  });
}
