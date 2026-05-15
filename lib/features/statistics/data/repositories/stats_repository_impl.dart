import 'package:focus_flow/core/utils/date_helpers.dart';
import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/entities/streak.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';
import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl({required SessionRepository sessionRepository})
      : _sessions = sessionRepository;

  final SessionRepository _sessions;

  @override
  Future<DailyStats> getStatsForDay(DateTime day) async {
    final sessions = await _sessions.getInRange(startOfDay(day), endOfDay(day));
    return _aggregate(day, sessions);
  }

  @override
  Future<DailyStats> getStatsForRange(DateTime start, DateTime end) async {
    final sessions = await _sessions.getInRange(start, end);
    return _aggregate(start, sessions);
  }

  @override
  Stream<DailyStats> watchToday() async* {
    yield await getStatsForDay(DateTime.now());
    await for (final _ in _sessions.watchChanges()) {
      yield await getStatsForDay(DateTime.now());
    }
  }

  @override
  Future<Streak> getStreak() async {
    final sessions = await _sessions.getInRange(
      DateTime(2000),
      DateTime.now().add(const Duration(days: 1)),
    );
    return _computeStreak(sessions);
  }

  @override
  Stream<Streak> watchStreak() async* {
    yield await getStreak();
    await for (final _ in _sessions.watchChanges()) {
      yield await getStreak();
    }
  }

  DailyStats _aggregate(DateTime day, List<PomodoroSession> sessions) {
    final work = sessions
        .where((s) => s.completed && s.type == SessionType.work)
        .toList();
    final totalSeconds = work.fold<int>(
      0,
      (sum, s) => sum + s.actualDuration.inSeconds,
    );
    return DailyStats(
      date: day,
      completedWorkSessions: work.length,
      totalFocusTime: Duration(seconds: totalSeconds),
    );
  }

  Streak _computeStreak(List<PomodoroSession> sessions) {
    final dayStarts = sessions
        .where((s) => s.completed && s.type == SessionType.work)
        .map((s) => startOfDay(s.completedAt))
        .toSet();

    if (dayStarts.isEmpty) return Streak.empty();

    final sortedDays = dayStarts.toList()..sort();
    final lastDay = sortedDays.last;

    var longest = 1;
    var run = 1;
    for (var i = 1; i < sortedDays.length; i++) {
      if (sortedDays[i].difference(sortedDays[i - 1]) ==
          const Duration(days: 1)) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }

    final today = startOfDay(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (!dayStarts.contains(today) && !dayStarts.contains(yesterday)) {
      return Streak(current: 0, longest: longest, lastCompletedDate: lastDay);
    }

    var current = 0;
    var check = dayStarts.contains(today) ? today : yesterday;
    while (dayStarts.contains(check)) {
      current++;
      check = check.subtract(const Duration(days: 1));
    }

    return Streak(
      current: current,
      longest: longest,
      lastCompletedDate: lastDay,
    );
  }
}
