import 'package:hive_ce/hive.dart';

import 'package:focus_flow/features/timer/data/models/session_model.dart';

class SessionLocalDataSource {
  SessionLocalDataSource({required Box<SessionModel> sessionsBox})
      : _box = sessionsBox;

  final Box<SessionModel> _box;

  Future<void> save(SessionModel session) async {
    await _box.put(session.id, session);
  }

  List<SessionModel> getInRange(DateTime start, DateTime end) {
    return _box.values
        .where((s) =>
            !s.completedAt.isBefore(start) && s.completedAt.isBefore(end))
        .toList();
  }

  Stream<BoxEvent> watch() => _box.watch();
}
