import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:focus_flow/app/di/injection.dart';
import 'package:focus_flow/app/router/scaffold_with_nav_bar.dart';
import 'package:focus_flow/features/settings/presentation/pages/settings_page.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/stats_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/streak_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/today_stats_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/pages/stats_page.dart';
import 'package:focus_flow/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:focus_flow/features/timer/presentation/pages/timer_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'timer',
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => TimerCubit(saveSession: sl())),
                BlocProvider(
                  create: (_) => TodayStatsCubit(watchTodayStats: sl()),
                ),
                BlocProvider(create: (_) => StreakCubit(watchStreak: sl())),
              ],
              child: const TimerPage(),
            ),
          ),
          GoRoute(
            path: '/stats',
            name: 'stats',
            builder: (context, state) => BlocProvider(
              create: (_) => StatsCubit(
                watchTodayStats: sl(),
                getWeekStats: sl(),
                getAllTimeStats: sl(),
                watchStreak: sl(),
              ),
              child: const StatsPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
