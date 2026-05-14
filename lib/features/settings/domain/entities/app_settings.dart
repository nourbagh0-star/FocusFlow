import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({this.dailyGoal = 4, this.notificationTime});

  final int dailyGoal;
  final String? notificationTime; // "HH:mm"

  AppSettings copyWith({
    int? dailyGoal,
    String? notificationTime,
    bool clearNotificationTime = false,
  }) {
    return AppSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notificationTime: clearNotificationTime
          ? null
          : (notificationTime ?? this.notificationTime),
    );
  }

  @override
  List<Object?> get props => [dailyGoal, notificationTime];
}
