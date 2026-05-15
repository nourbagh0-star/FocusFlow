import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';

import 'package:focus_flow/core/constants/hive_boxes.dart';
import 'package:focus_flow/core/services/audio_service.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:focus_flow/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:focus_flow/features/settings/domain/repositories/settings_repository.dart';
import 'package:focus_flow/features/settings/domain/usecases/get_app_settings.dart';
import 'package:focus_flow/features/settings/domain/usecases/update_app_settings.dart';
import 'package:focus_flow/features/settings/domain/usecases/watch_app_settings.dart';
import 'package:focus_flow/features/statistics/data/repositories/stats_repository_impl.dart';
import 'package:focus_flow/features/statistics/domain/repositories/stats_repository.dart';
import 'package:focus_flow/features/statistics/domain/usecases/get_streak.dart';
import 'package:focus_flow/features/statistics/domain/usecases/get_today_stats.dart';
import 'package:focus_flow/features/statistics/domain/usecases/watch_streak.dart';
import 'package:focus_flow/features/statistics/domain/usecases/watch_today_stats.dart';
import 'package:focus_flow/features/timer/data/datasources/session_local_datasource.dart';
import 'package:focus_flow/features/timer/data/models/session_model.dart';
import 'package:focus_flow/features/timer/data/repositories/session_repository_impl.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';
import 'package:focus_flow/features/timer/domain/usecases/export_sessions_csv.dart';
import 'package:focus_flow/features/timer/domain/usecases/get_today_sessions.dart';
import 'package:focus_flow/features/timer/domain/usecases/save_session.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ── Hive boxes ─────────────────────────────────────────
  final sessionsBox =
      await Hive.openBox<SessionModel>(HiveBoxes.sessions);
  final settingsBox = await Hive.openBox<dynamic>(HiveBoxes.settings);

  // ── Services ───────────────────────────────────────────
  sl.registerLazySingleton<AudioService>(AudioService.new);
  sl.registerLazySingleton<NotificationService>(NotificationService.new);

  // ── Data sources ───────────────────────────────────────
  sl.registerSingleton<SessionLocalDataSource>(
    SessionLocalDataSource(sessionsBox: sessionsBox),
  );
  sl.registerSingleton<SettingsLocalDataSource>(
    SettingsLocalDataSource(box: settingsBox),
  );

  // ── Repositories ───────────────────────────────────────
  sl.registerSingleton<SessionRepository>(
    SessionRepositoryImpl(local: sl()),
  );
  sl.registerSingleton<StatsRepository>(
    StatsRepositoryImpl(sessionRepository: sl()),
  );
  sl.registerSingleton<SettingsRepository>(
    SettingsRepositoryImpl(local: sl()),
  );

  // ── Use cases ──────────────────────────────────────────
  sl.registerSingleton<SaveSession>(SaveSession(sl()));
  sl.registerSingleton<GetTodaySessions>(GetTodaySessions(sl()));
  sl.registerSingleton<ExportSessionsCsv>(ExportSessionsCsv(sl()));
  sl.registerSingleton<GetTodayStats>(GetTodayStats(sl()));
  sl.registerSingleton<WatchTodayStats>(WatchTodayStats(sl()));
  sl.registerSingleton<GetStreak>(GetStreak(sl()));
  sl.registerSingleton<WatchStreak>(WatchStreak(sl()));
  sl.registerSingleton<GetAppSettings>(GetAppSettings(sl()));
  sl.registerSingleton<UpdateAppSettings>(UpdateAppSettings(sl()));
  sl.registerSingleton<WatchAppSettings>(WatchAppSettings(sl()));

  // ── Cubits ─────────────────────────────────────────────
  // Cubits use BlocProvider, not GetIt — keep this section empty.
}
