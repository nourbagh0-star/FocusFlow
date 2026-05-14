import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:focus_flow/app/app.dart';
import 'package:focus_flow/app/di/injection.dart';
import 'package:focus_flow/core/services/notification_service.dart';
import 'package:focus_flow/hive_registrar.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapters();

  await setupDependencies();
  await sl<NotificationService>().init();

  runApp(const FocusFlowApp());
}
