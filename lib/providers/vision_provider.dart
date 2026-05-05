import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/vision_service.dart';

final visionServiceProvider = Provider<VisionService>((ref) {
  final service = VisionService();
  ref.onDispose(service.dispose);
  return service;
});
