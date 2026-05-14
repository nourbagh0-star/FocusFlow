import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';
import 'package:focus_flow/features/settings/domain/repositories/settings_repository.dart';

class WatchAppSettings {
  const WatchAppSettings(this._repository);

  final SettingsRepository _repository;

  Stream<AppSettings> call() => _repository.watch();
}
