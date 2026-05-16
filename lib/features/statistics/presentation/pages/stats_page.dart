import 'package:fl_chart/fl_chart.dart';
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
              _WeekChartCard(days: state.weekDays, weekTotal: state.thisWeek),
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

class _WeekChartCard extends StatelessWidget {
  const _WeekChartCard({required this.days, required this.weekTotal});

  final List<DailyStats> days;
  final DailyStats weekTotal;

  @override
  Widget build(BuildContext context) {
    return _StatsCard(
      label: 'This week',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 120, child: _WeekBarChart(days: days)),
          const SizedBox(height: 12),
          _StatCell(
            value: _formatFocusTime(weekTotal.totalFocusTime),
            label: 'focused',
          ),
        ],
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  const _WeekBarChart({required this.days});

  final List<DailyStats> days;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final todayIndex = DateTime.now().weekday - 1;

    final maxSessions = days.fold(0, (m, d) => d.completedWorkSessions > m ? d.completedWorkSessions : m);
    final maxY = (maxSessions + 1).clamp(4, double.infinity).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                return Text(
                  _labels[i],
                  style: Theme.of(context).textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          final sessions = days[i].completedWorkSessions.toDouble();
          final barColor = i == todayIndex
              ? color
              : i < todayIndex
                  ? color.withValues(alpha: 0.35)
                  : color.withValues(alpha: 0.12);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: sessions > 0 ? sessions : (i <= todayIndex ? 0 : 0),
                color: barColor,
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
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
