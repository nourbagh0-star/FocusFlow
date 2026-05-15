import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/app/di/injection.dart';
import 'package:focus_flow/core/services/audio_service.dart';
import 'package:focus_flow/core/utils/duration_formatter.dart';
import 'package:focus_flow/features/statistics/presentation/widgets/today_summary.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';
import 'package:focus_flow/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:focus_flow/features/timer/presentation/cubit/timer_state.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FocusFlow')),
      body: BlocListener<TimerCubit, TimerState>(
        listenWhen: (prev, curr) =>
            prev is! TimerCompleted && curr is TimerCompleted,
        listener: (context, _) {
          sl<AudioService>().playCompletionSound();
        },
        child: BlocBuilder<TimerCubit, TimerState>(
          builder: (context, state) {
            final display = switch (state) {
              TimerInitial(:final duration) => formatDuration(duration),
              TimerRunning(:final remaining) => formatDuration(remaining),
              TimerPaused(:final remaining) => formatDuration(remaining),
              TimerCompleted() => '00:00',
            };

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PhaseChip(type: _typeOfState(state)),
                  const SizedBox(height: 16),
                  Text(
                    display,
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _Controls(state: state),
                  const SizedBox(height: 48),
                  const TodaySummary(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Helper to extract type from any state (mirrors TimerCubit._typeOf).
SessionType _typeOfState(TimerState state) => switch (state) {
      TimerInitial(:final type) => type,
      TimerRunning(:final type) => type,
      TimerPaused(:final type) => type,
      TimerCompleted(:final type) => type,
    };

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.type});

  final SessionType type;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(_label(type)),
      visualDensity: VisualDensity.compact,
    );
  }

  String _label(SessionType type) => switch (type) {
        SessionType.work => 'Work',
        SessionType.shortBreak => 'Short break',
        SessionType.longBreak => 'Long break',
      };
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});

  final TimerState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TimerCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        switch (state) {
          TimerInitial() => FilledButton(
              onPressed: cubit.start,
              child: const Text('Start'),
            ),
          TimerRunning() => FilledButton(
              onPressed: cubit.pause,
              child: const Text('Pause'),
            ),
          TimerPaused() => FilledButton(
              onPressed: cubit.resume,
              child: const Text('Resume'),
            ),
          TimerCompleted(:final nextType) => FilledButton(
              onPressed: cubit.startNextPhase,
              child: Text(_nextLabel(nextType)),
            ),
        },
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: cubit.reset,
          child: const Text('Reset'),
        ),
      ],
    );
  }

  String _nextLabel(SessionType type) => switch (type) {
        SessionType.work => 'Start work',
        SessionType.shortBreak => 'Start break',
        SessionType.longBreak => 'Start long break',
      };
}
