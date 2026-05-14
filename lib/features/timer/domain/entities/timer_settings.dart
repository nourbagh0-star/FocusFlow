import 'package:equatable/equatable.dart';

import 'session_type.dart';

class TimerSettings extends Equatable {
  const TimerSettings({
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.sessionsUntilLongBreak,
  });

  final Duration workDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
  final int sessionsUntilLongBreak;

  static const TimerSettings standard = TimerSettings(
    workDuration: Duration(minutes: 25),
    shortBreakDuration: Duration(minutes: 5),
    longBreakDuration: Duration(minutes: 15),
    sessionsUntilLongBreak: 4,
  );

  Duration durationFor(SessionType type) => switch (type) {
        SessionType.work => workDuration,
        SessionType.shortBreak => shortBreakDuration,
        SessionType.longBreak => longBreakDuration,
      };

  @override
  List<Object?> get props => [
        workDuration,
        shortBreakDuration,
        longBreakDuration,
        sessionsUntilLongBreak,
      ];
}
