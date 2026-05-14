import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/features/statistics/domain/entities/streak.dart';
import 'package:focus_flow/features/statistics/domain/usecases/watch_streak.dart';
import 'streak_state.dart';

class StreakCubit extends Cubit<StreakState> {
  StreakCubit({required WatchStreak watchStreak})
      : _watch = watchStreak,
        super(StreakState.initial()) {
    _sub = _watch().listen((streak) {
      if (isClosed) return;
      emit(StreakState(streak: streak));
    });
  }

  final WatchStreak _watch;
  StreamSubscription<Streak>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
