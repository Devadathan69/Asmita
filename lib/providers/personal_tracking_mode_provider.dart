import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_profile_provider.dart';

enum PersonalTrackingMode { cycle, pregnancy }

final personalTrackingModeProvider = Provider<PersonalTrackingMode>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  return profile?.isPregnant == true
      ? PersonalTrackingMode.pregnancy
      : PersonalTrackingMode.cycle;
});
