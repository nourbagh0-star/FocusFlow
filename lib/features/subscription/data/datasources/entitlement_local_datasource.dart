import 'package:hive_ce/hive.dart';

import 'package:focus_flow/features/subscription/data/models/entitlement_model.dart';

class EntitlementLocalDataSource {
  EntitlementLocalDataSource({required Box<EntitlementModel> box}) : _box = box;

  final Box<EntitlementModel> _box;

  static const String _key = 'current';

  EntitlementModel? get() => _box.get(_key);

  Future<void> save(EntitlementModel entitlement) async {
    await _box.put(_key, entitlement);
  }

  Future<void> clear() async {
    await _box.delete(_key);
  }
}
