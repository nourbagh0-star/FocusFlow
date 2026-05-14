import 'package:equatable/equatable.dart';

import 'package:focus_flow/features/timer/domain/entities/session_type.dart';

sealed class TimerState extends Equatable {
  const TimerState();
}

class TimerInitial extends TimerState {
  const TimerInitial({required this.type, required this.duration});

  final SessionType type;
  final Duration duration;

  @override
  List<Object?> get props => [type, duration];
}

class TimerRunning extends TimerState {
  const TimerRunning({
    required this.type,
    required this.remaining,
    required this.total,
  });

  final SessionType type;
  final Duration remaining;
  final Duration total;

  @override
  List<Object?> get props => [type, remaining, total];
}

class TimerPaused extends TimerState {
  const TimerPaused({
    required this.type,
    required this.remaining,
    required this.total,
  });

  final SessionType type;
  final Duration remaining;
  final Duration total;

  @override
  List<Object?> get props => [type, remaining, total];
}

class TimerCompleted extends TimerState {
  const TimerCompleted({
    required this.type,
    required this.plannedDuration,
    required this.nextType,
  });

  final SessionType type;
  final Duration plannedDuration;
  final SessionType nextType;

  @override
  List<Object?> get props => [type, plannedDuration, nextType];
}
