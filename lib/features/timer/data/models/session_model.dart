import 'package:hive_ce/hive.dart';

import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)
class SessionModel {
  SessionModel({
    required this.id,
    required this.typeIndex,
    required this.startedAt,
    required this.completedAt,
    required this.plannedDurationSeconds,
    required this.actualDurationSeconds,
    required this.completed,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final int typeIndex;

  @HiveField(2)
  final DateTime startedAt;

  @HiveField(3)
  final DateTime completedAt;

  @HiveField(4)
  final int plannedDurationSeconds;

  @HiveField(5)
  final int actualDurationSeconds;

  @HiveField(6)
  final bool completed;

  factory SessionModel.fromEntity(PomodoroSession s) => SessionModel(
        id: s.id,
        typeIndex: s.type.index,
        startedAt: s.startedAt,
        completedAt: s.completedAt,
        plannedDurationSeconds: s.plannedDuration.inSeconds,
        actualDurationSeconds: s.actualDuration.inSeconds,
        completed: s.completed,
      );

  PomodoroSession toEntity() => PomodoroSession(
        id: id,
        type: SessionType.values[typeIndex],
        startedAt: startedAt,
        completedAt: completedAt,
        plannedDuration: Duration(seconds: plannedDurationSeconds),
        actualDuration: Duration(seconds: actualDurationSeconds),
        completed: completed,
      );
}
