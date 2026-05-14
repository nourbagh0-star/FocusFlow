import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';
import 'package:focus_flow/features/settings/domain/repositories/settings_repository.dart';

class UpdateAppSettings {
  const UpdateAppSettings(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppSettings settings) => _repository.update(settings);
}
