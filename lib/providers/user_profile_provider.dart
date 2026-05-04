import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../db/models/user_profile.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);

class UserProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() => DatabaseHelper.instance.getProfile();

  Future<void> save(UserProfile profile) async {
    await DatabaseHelper.instance.saveProfile(profile);
    state = AsyncData(profile);
  }
}
