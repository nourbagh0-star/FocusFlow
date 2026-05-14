import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:focus_flow/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:focus_flow/features/settings/presentation/cubit/settings_state.dart';
import 'package:focus_flow/features/statistics/domain/entities/daily_stats.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/streak_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/streak_state.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/today_stats_cubit.dart';
import 'package:focus_flow/features/statistics/presentation/cubit/today_stats_state.dart';
import 'package:focus_flow/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:focus_flow/features/subscription/presentation/cubit/subscription_state.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';
import 'package:focus_flow/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:focus_flow/features/timer/presentation/cubit/timer_state.dart';
import 'package:focus_flow/features/timer/presentation/pages/timer_page.dart';

class MockTimerCubit extends MockCubit<TimerState> implements TimerCubit {}

class MockTodayStatsCubit extends MockCubit<TodayStatsState>
    implements TodayStatsCubit {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockStreakCubit extends MockCubit<StreakState> implements StreakCubit {}

class MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}

void main() {
  testWidgets('TimerPage renders 25:00 and Start button at initial state',
      (tester) async {
    final timerCubit = MockTimerCubit();
    final statsCubit = MockTodayStatsCubit();
    final settingsCubit = MockSettingsCubit();
    final streakCubit = MockStreakCubit();
    final subscriptionCubit = MockSubscriptionCubit();

    when(() => timerCubit.state).thenReturn(
      const TimerInitial(
        type: SessionType.work,
        duration: Duration(minutes: 25),
      ),
    );
    when(() => statsCubit.state).thenReturn(
      TodayStatsLoaded(DailyStats.empty(DateTime(2026, 5, 13))),
    );
    when(() => settingsCubit.state).thenReturn(SettingsState.initial());
    when(() => streakCubit.state).thenReturn(StreakState.initial());
    when(() => subscriptionCubit.state)
        .thenReturn(SubscriptionState.initial());

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TimerCubit>.value(value: timerCubit),
            BlocProvider<TodayStatsCubit>.value(value: statsCubit),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
            BlocProvider<StreakCubit>.value(value: streakCubit),
            BlocProvider<SubscriptionCubit>.value(value: subscriptionCubit),
          ],
          child: const TimerPage(),
        ),
      ),
    );

    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });
}
