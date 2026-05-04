import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Map<String, Object>>(
  SettingsNotifier.new,
);

class SettingsNotifier extends AsyncNotifier<Map<String, Object>> {
  @override
  Future<Map<String, Object>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return {'reduceMotion': prefs.getBool('reduceMotion') ?? false};
  }

  Future<void> setReduceMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceMotion', value);
    state = AsyncData({...state.value ?? {}, 'reduceMotion': value});
  }
}
