import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/settings/domain/entities/app_settings.dart';
import 'package:focus_flow/features/settings/domain/usecases/get_app_settings.dart';
import 'package:focus_flow/features/settings/domain/usecases/update_app_settings.dart';
import 'package:focus_flow/features/settings/domain/usecases/watch_app_settings.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required GetAppSettings getAppSettings,
    required UpdateAppSettings updateAppSettings,
    required WatchAppSettings watchAppSettings,
    required NotificationService notificationService,
  })  : _update = updateAppSettings,
        _notifications = notificationService,
        super(SettingsState(settings: getAppSettings())) {
    _sub = watchAppSettings().listen((settings) {
      if (isClosed) return;
      emit(SettingsState(settings: settings));
    });
  }

  final UpdateAppSettings _update;
  final NotificationService _notifications;
  StreamSubscription<AppSettings>? _sub;

  Future<void> setDailyGoal(int value) async {
    await _update(state.settings.copyWith(dailyGoal: value));
  }

  Future<void> setNotificationTime(String? time) async {
    await _update(state.settings.copyWith(
      notificationTime: time,
      clearNotificationTime: time == null,
    ));

    if (time == null) {
      await _notifications.cancelDailyReminder();
    } else {
      final parts = time.split(':');
      await _notifications.scheduleDailyReminder(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
