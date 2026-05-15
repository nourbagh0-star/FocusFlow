import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/domain/entities/streak.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/stats_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/stats_state.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TodayCard(stats: state.today),
              const SizedBox(height: 12),
              _WeekCard(stats: state.thisWeek),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _AllTimeCard(stats: state.allTime)),
                    const SizedBox(width: 12),
                    Expanded(child: _StreakCard(streak: state.streak)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.stats});

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return _StatsCard(
      label: 'Today',
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '${stats.completedWorkSessions}',
              label: 'sessions',
            ),
          ),
          Expanded(
            child: _StatCell(
              value: '${stats.totalFocusTime.inMinutes}',
              label: 'min focused',
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.stats});

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return _StatsCard(
      label: 'This week',
      child: _StatCell(
        value: _formatFocusTime(stats.totalFocusTime),
        label: 'focused',
      ),
    );
  }
}

class _AllTimeCard extends StatelessWidget {
  const _AllTimeCard({required this.stats});

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    return _StatsCard(
      label: 'All time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatCell(
            value: '${stats.completedWorkSessions}',
            label: 'sessions',
          ),
          const SizedBox(height: 12),
          _StatCell(
            value: '${stats.totalFocusTime.inHours}',
            label: 'hours',
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});

  final Streak streak;

  @override
  Widget build(BuildContext context) {
    final days = streak.longest;
    return _StatsCard(
      label: 'Longest streak',
      child: _StatCell(
        value: '$days',
        label: days == 1 ? 'day' : 'days',
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

String _formatFocusTime(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours == 0) return '$minutes min';
  if (minutes == 0) return '$hours h';
  return '$hours h $minutes min';
}
