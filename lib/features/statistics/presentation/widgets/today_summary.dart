import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_state.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/streak_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/streak_state.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/today_stats_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/today_stats_state.dart';

class TodaySummary extends StatelessWidget {
  const TodaySummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return BlocBuilder<TodayStatsCubit, TodayStatsState>(
      builder: (context, statsState) {
        final text = switch (statsState) {
          TodayStatsLoading() => null,
          TodayStatsLoaded(:final stats) => BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final goal = settingsState.settings.dailyGoal;
                return Text(
                  '${stats.completedWorkSessions} / $goal sessions today  •  ${stats.totalFocusTime.inMinutes} min focused',
                  style: muted,
                );
              },
            ),
          TodayStatsError(:final message) => Text(
              'Stats unavailable: $message',
              style: muted,
            ),
        };

        return Column(
          children: [
            ?text,
            const SizedBox(height: 8),
            BlocBuilder<StreakCubit, StreakState>(
              builder: (context, streakState) {
                if (streakState.streak.current == 0) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_fire_department, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${streakState.streak.current} day streak',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
