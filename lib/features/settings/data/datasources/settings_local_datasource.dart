import 'package:hive_ce/hive.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource({required Box<dynamic> box}) : _box = box;

  final Box<dynamic> _box;

  static const String _keyDailyGoal = 'daily_goal';
  static const String _keyNotificationTime = 'notification_time';

  int getDailyGoal({int defaultValue = 4}) =>
      (_box.get(_keyDailyGoal) as int?) ?? defaultValue;

  Future<void> setDailyGoal(int value) => _box.put(_keyDailyGoal, value);

  String? getNotificationTime() =>
      _box.get(_keyNotificationTime) as String?;

  Future<void> setNotificationTime(String? value) async {
    if (value == null) {
      await _box.delete(_keyNotificationTime);
    } else {
      await _box.put(_keyNotificationTime, value);
    }
  }

  Stream<BoxEvent> watch() => _box.watch();
}
