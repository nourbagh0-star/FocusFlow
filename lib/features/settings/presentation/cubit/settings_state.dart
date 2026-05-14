import 'package:equatable/equatable.dart';

import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';

class SettingsState extends Equatable {
  const SettingsState({required this.settings});

  factory SettingsState.initial() =>
      const SettingsState(settings: AppSettings());

  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}
