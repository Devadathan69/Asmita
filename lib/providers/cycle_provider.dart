import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../db/models/cycle_entry.dart';

final cycleProvider = AsyncNotifierProvider<CycleNotifier, List<CycleEntry>>(
  CycleNotifier.new,
);

class CycleNotifier extends AsyncNotifier<List<CycleEntry>> {
  @override
  Future<List<CycleEntry>> build() => DatabaseHelper.instance.cycles();

  Future<void> add(CycleEntry entry) async {
    await DatabaseHelper.instance.insertCycle(entry);
    state = AsyncData(await DatabaseHelper.instance.cycles());
  }
}
