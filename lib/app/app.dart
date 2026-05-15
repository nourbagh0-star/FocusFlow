import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/app/di/injection.dart';
import 'package:focus_flow/app/router/app_router.dart';
import 'package:focus_flow/core/theme/app_theme.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            getAppSettings: sl(),
            updateAppSettings: sl(),
            watchAppSettings: sl(),
            notificationService: sl(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'FocusFlow',
        theme: AppTheme.light(),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
