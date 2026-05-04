import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../db/models/daily_log.dart';

final logProvider = AsyncNotifierProvider<LogNotifier, List<DailyLog>>(
  LogNotifier.new,
);

class LogNotifier extends AsyncNotifier<List<DailyLog>> {
  @override
  Future<List<DailyLog>> build() => DatabaseHelper.instance.logs();

  Future<void> save(DailyLog log) async {
    await DatabaseHelper.instance.upsertLog(log);
    state = AsyncData(await DatabaseHelper.instance.logs());
  }
}
