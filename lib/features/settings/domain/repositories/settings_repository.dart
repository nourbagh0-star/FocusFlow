import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  AppSettings getCurrent();

  Future<void> update(AppSettings settings);

  Stream<AppSettings> watch();
}
