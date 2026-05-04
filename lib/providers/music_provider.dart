import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/music_service.dart';

final musicServiceProvider = Provider<MusicService>((ref) {
  final service = MusicService();
  ref.onDispose(service.dispose);
  return service;
});
