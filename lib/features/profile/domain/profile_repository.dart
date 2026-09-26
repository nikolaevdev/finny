import 'player_profile.dart';

abstract interface class ProfileRepository {
  PlayerProfile? load();

  Future<void> save(PlayerProfile profile);

  Future<void> delete();
}
