import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/entities/session_type.dart';
import 'package:focus_flow/features/timer/domain/entities/timer_settings.dart';
import 'package:focus_flow/features/timer/domain/usecases/save_session.dart';
import 'package:focus_flow/features/timer/presentation/cubit/timer_cubit.dart';
import 'package:focus_flow/features/timer/presentation/cubit/timer_state.dart';

class MockSaveSession extends Mock implements SaveSession {}

void main() {
  const testSettings = TimerSettings(
    workDuration: Duration(seconds: 3),
    shortBreakDuration: Duration(seconds: 1),
    longBreakDuration: Duration(seconds: 2),
    sessionsUntilLongBreak: 4,
  );

  late MockSaveSession saveSession;

  setUpAll(() {
    registerFallbackValue(PomodoroSession(
      id: 'fallback',
      type: SessionType.work,
      startedAt: DateTime(2026),
      completedAt: DateTime(2026),
      plannedDuration: Duration.zero,
      actualDuration: Duration.zero,
      completed: true,
    ));
  });

  setUp(() {
    saveSession = MockSaveSession();
    when(() => saveSession(any())).thenAnswer((_) async {});
  });

  group('TimerCubit — basic transitions', () {
    test('initial state is TimerInitial with work duration', () {
      final cubit = TimerCubit(
        saveSession: saveSession,
        settings: testSettings,
      );
      expect(
        cubit.state,
        const TimerInitial(
          type: SessionType.work,
          duration: Duration(seconds: 3),
        ),
      );
      cubit.close();
    });

    blocTest<TimerCubit, TimerState>(
      'emits TimerRunning when start() called from initial',
      build: () => TimerCubit(
        saveSession: saveSession,
        settings: testSettings,
      ),
      act: (cubit) => cubit.start(),
      expect: () => [
        const TimerRunning(
          type: SessionType.work,
          total: Duration(seconds: 3),
          remaining: Duration(seconds: 3),
        ),
      ],
    );

    blocTest<TimerCubit, TimerState>(
      'pause() from Running emits TimerPaused',
      build: () => TimerCubit(
        saveSession: saveSession,
        settings: testSettings,
      ),
      act: (cubit) {
        cubit.start();
        cubit.pause();
      },
      expect: () => [
        isA<TimerRunning>(),
        isA<TimerPaused>(),
      ],
    );
  });

  group('TimerCubit — completion and cycle', () {
    test('ticks down to zero, saves session, emits TimerCompleted', () {
      fakeAsync((async) {
        final cubit = TimerCubit(
          saveSession: saveSession,
          settings: testSettings,
        );
        final emitted = <TimerState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.start();
        async.elapse(const Duration(seconds: 5));

        expect(emitted.last, isA<TimerCompleted>());
        final completed = emitted.last as TimerCompleted;
        expect(completed.type, SessionType.work);
        expect(completed.nextType, SessionType.shortBreak);
        verify(() => saveSession(any())).called(1);

        sub.cancel();
        cubit.close();
      });
    });

    test('after 4 work sessions, nextType is longBreak', () {
      fakeAsync((async) {
        final cubit = TimerCubit(
          saveSession: saveSession,
          settings: testSettings,
        );

        for (var i = 0; i < 3; i++) {
          cubit.start();
          async.elapse(const Duration(seconds: 5));
          cubit.startNextPhase(); // → Initial(shortBreak)
          cubit.start();
          async.elapse(const Duration(seconds: 3));
          cubit.startNextPhase(); // → Initial(work)
        }
        // 4th work session
        cubit.start();
        async.elapse(const Duration(seconds: 5));

        expect(cubit.state, isA<TimerCompleted>());
        expect((cubit.state as TimerCompleted).nextType, SessionType.longBreak);

        cubit.close();
      });
    });

    test('startNextPhase from Completed emits Initial of nextType', () {
      fakeAsync((async) {
        final cubit = TimerCubit(
          saveSession: saveSession,
          settings: testSettings,
        );
        cubit.start();
        async.elapse(const Duration(seconds: 5));
        cubit.startNextPhase();

        expect(cubit.state, isA<TimerInitial>());
        expect((cubit.state as TimerInitial).type, SessionType.shortBreak);

        cubit.close();
      });
    });
  });

  group('TimerCubit — lifecycle', () {
    test('close() cancels the ticker so no late emits occur', () {
      fakeAsync((async) {
        final cubit = TimerCubit(
          saveSession: saveSession,
          settings: testSettings,
        );
        cubit.start();
        cubit.close();

        expect(
          () => async.elapse(const Duration(seconds: 5)),
          returnsNormally,
        );
      });
    });
  });
}
