import 'package:equatable/equatable.dart';

class DailyStats extends Equatable {
  const DailyStats({
    required this.date,
    required this.completedWorkSessions,
    required this.totalFocusTime,
  });

  final DateTime date;
  final int completedWorkSessions;
  final Duration totalFocusTime;

  factory DailyStats.empty(DateTime date) => DailyStats(
        date: date,
        completedWorkSessions: 0,
        totalFocusTime: Duration.zero,
      );

  @override
  List<Object?> get props => [date, completedWorkSessions, totalFocusTime];
}
