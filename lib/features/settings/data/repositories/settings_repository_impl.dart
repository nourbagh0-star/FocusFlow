import 'package:focus_flow/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';
import 'package:focus_flow/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required SettingsLocalDataSource local})
      : _local = local;

  final SettingsLocalDataSource _local;

  @override
  AppSettings getCurrent() => AppSettings(
        dailyGoal: _local.getDailyGoal(),
        notificationTime: _local.getNotificationTime(),
      );

  @override
  Future<void> update(AppSettings settings) async {
    await _local.setDailyGoal(settings.dailyGoal);
    await _local.setNotificationTime(settings.notificationTime);
  }

  @override
  Stream<AppSettings> watch() async* {
    yield getCurrent();
    await for (final _ in _local.watch()) {
      yield getCurrent();
    }
  }
}
