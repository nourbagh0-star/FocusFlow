import 'package:focus_flow/features/timer/data/datasources/session_local_datasource.dart';
import 'package:focus_flow/features/timer/data/models/session_model.dart';
import 'package:focus_flow/features/timer/domain/entities/pomodoro_session.dart';
import 'package:focus_flow/features/timer/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl({required SessionLocalDataSource local}) : _local = local;

  final SessionLocalDataSource _local;

  @override
  Future<void> save(PomodoroSession session) async {
    await _local.save(SessionModel.fromEntity(session));
  }

  @override
  Future<List<PomodoroSession>> getInRange(DateTime start, DateTime end) async {
    return _local.getInRange(start, end).map((m) => m.toEntity()).toList();
  }

  @override
  Stream<void> watchChanges() => _local.watch().map<void>((_) {});
}
