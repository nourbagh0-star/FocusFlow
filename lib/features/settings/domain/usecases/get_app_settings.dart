import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';
import 'package:focus_flow/features/settings/domain/repositories/settings_repository.dart';

class GetAppSettings {
  const GetAppSettings(this._repository);

  final SettingsRepository _repository;

  AppSettings call() => _repository.getCurrent();
}
