import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
import 'package:focus_flow/features/subscription/data/datasources/entitlement_local_datasource.dart';
import 'package:focus_flow/features/subscription/data/models/entitlement_model.dart';
import 'package:focus_flow/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:focus_flow/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:focus_flow/features/subscription/domain/usecases/get_products.dart';
import 'package:focus_flow/features/subscription/domain/usecases/purchase_product.dart';
import 'package:focus_flow/features/subscription/domain/usecases/restore_purchases.dart';
import 'package:focus_flow/features/subscription/domain/usecases/watch_purchase_events.dart';
import 'package:focus_flow/features/subscription/domain/usecases/watch_subscription_status.dart';
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
  final entitlementBox =
      await Hive.openBox<EntitlementModel>(HiveBoxes.entitlement);
  final settingsBox = await Hive.openBox<dynamic>(HiveBoxes.settings);

  // ── Services ───────────────────────────────────────────
  sl.registerLazySingleton<AudioService>(AudioService.new);
  sl.registerLazySingleton<NotificationService>(NotificationService.new);

  // ── Data sources ───────────────────────────────────────
  sl.registerSingleton<SessionLocalDataSource>(
    SessionLocalDataSource(sessionsBox: sessionsBox),
  );
  sl.registerSingleton<EntitlementLocalDataSource>(
    EntitlementLocalDataSource(box: entitlementBox),
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
  sl.registerSingleton<SubscriptionRepository>(
    SubscriptionRepositoryImpl(
      iap: InAppPurchase.instance,
      cache: sl(),
    ),
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
  sl.registerSingleton<GetProducts>(GetProducts(sl()));
  sl.registerSingleton<PurchaseProduct>(PurchaseProduct(sl()));
  sl.registerSingleton<RestorePurchases>(RestorePurchases(sl()));
  sl.registerSingleton<WatchSubscriptionStatus>(WatchSubscriptionStatus(sl()));
  sl.registerSingleton<WatchPurchaseEvents>(WatchPurchaseEvents(sl()));

  // ── Cubits ─────────────────────────────────────────────
  // Cubits use BlocProvider, not GetIt — keep this section empty.
}
