import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';
import 'package:focus_flow/features/timer/domain/entities/timer_settings.dart';
import 'package:focus_flow/features/timer/domain/usecases/save_session.dart';
import 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  TimerCubit({
    required SaveSession saveSession,
    TimerSettings settings = TimerSettings.standard,
    SessionType initialType = SessionType.work,
  })  : _saveSession = saveSession,
        _settings = settings,
        super(TimerInitial(
          type: initialType,
          duration: settings.durationFor(initialType),
        ));

  final SaveSession _saveSession;
  final TimerSettings _settings;
  final Uuid _uuid = const Uuid();

  Timer? _ticker;
  DateTime? _startedAt;
  int _completedWorkSessions = 0;

  static const Duration _tickInterval = Duration(seconds: 1);

  void start() {
    final current = state;
    if (current is! TimerInitial) return;
    _startedAt = DateTime.now();
    _runTicker(
      type: current.type,
      total: current.duration,
      remaining: current.duration,
    );
  }

  void pause() {
    final current = state;
    if (current is! TimerRunning) return;
    _ticker?.cancel();
    emit(TimerPaused(
      type: current.type,
      remaining: current.remaining,
      total: current.total,
    ));
  }

  void resume() {
    final current = state;
    if (current is! TimerPaused) return;
    _runTicker(
      type: current.type,
      total: current.total,
      remaining: current.remaining,
    );
  }

  void reset() {
    _ticker?.cancel();
    _startedAt = null;
    final type = _typeOf(state);
    emit(TimerInitial(type: type, duration: _settings.durationFor(type)));
  }

  void startNextPhase() {
    final current = state;
    if (current is! TimerCompleted) return;
    final next = current.nextType;
    emit(TimerInitial(type: next, duration: _settings.durationFor(next)));
  }

  void _runTicker({
    required SessionType type,
    required Duration total,
    required Duration remaining,
  }) {
    emit(TimerRunning(type: type, total: total, remaining: remaining));
    _ticker?.cancel();
    _ticker = Timer.periodic(_tickInterval, (_) => _onTick());
  }

  void _onTick() {
    final current = state;
    if (current is! TimerRunning) return;

    final next = current.remaining - _tickInterval;
    if (next <= Duration.zero) {
      _ticker?.cancel();
      _completePhase(current);
    } else {
      emit(TimerRunning(
        type: current.type,
        total: current.total,
        remaining: next,
      ));
    }
  }

  Future<void> _completePhase(TimerRunning finished) async {
    if (finished.type == SessionType.work) {
      _completedWorkSessions++;
    } else if (finished.type == SessionType.longBreak) {
      _completedWorkSessions = 0;
    }

    if (_startedAt != null) {
      try {
        await _saveSession(PomodoroSession(
          id: _uuid.v4(),
          type: finished.type,
          startedAt: _startedAt!,
          completedAt: DateTime.now(),
          plannedDuration: finished.total,
          actualDuration: finished.total,
          completed: true,
        ));
      } catch (_) {
        // Persistence failure shouldn't block the state machine.
      }
    }
    _startedAt = null;

    if (isClosed) return;
    emit(TimerCompleted(
      type: finished.type,
      plannedDuration: finished.total,
      nextType: _computeNextType(finished.type),
    ));
  }

  SessionType _computeNextType(SessionType justFinished) {
    if (justFinished != SessionType.work) {
      return SessionType.work;
    }
    final hitsLongBreak =
        _completedWorkSessions % _settings.sessionsUntilLongBreak == 0;
    return hitsLongBreak ? SessionType.longBreak : SessionType.shortBreak;
  }

  static SessionType _typeOf(TimerState state) => switch (state) {
        TimerInitial(:final type) => type,
        TimerRunning(:final type) => type,
        TimerPaused(:final type) => type,
        TimerCompleted(:final type) => type,
      };

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
