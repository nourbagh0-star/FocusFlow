import 'package:equatable/equatable.dart';

import 'session_type.dart';

class PomodoroSession extends Equatable {
  const PomodoroSession({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.completedAt,
    required this.plannedDuration,
    required this.actualDuration,
    required this.completed,
  });

  final String id;
  final SessionType type;
  final DateTime startedAt;
  final DateTime completedAt;
  final Duration plannedDuration;
  final Duration actualDuration;
  final bool completed;

  @override
  List<Object?> get props => [
        id,
        type,
        startedAt,
        completedAt,
        plannedDuration,
        actualDuration,
        completed,
      ];
}
