import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pet/domain/pet.dart';
import '../../pet/domain/pet_appearance.dart';
import '../domain/player_profile.dart';
import '../domain/profile_repository.dart';
import 'draft_profile_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw StateError('profileRepositoryProvider must be overridden at startup');
});

final initialProfileProvider = Provider<PlayerProfile?>((ref) => null);

class LocalProfileNotifier extends Notifier<PlayerProfile?> {
  @override
  PlayerProfile? build() => ref.watch(initialProfileProvider);

  Future<void> createFromDraft(DraftProfile draft) async {
    final playerName = draft.playerName.trim();
    final petName = draft.petName.trim();

    if (playerName.isEmpty || petName.isEmpty) {
      throw StateError('Имя игрока и имя питомца обязательны');
    }

    final profile = PlayerProfile(
      playerName: playerName,
      demoMode: draft.demoMode,
      pet: Pet(
        name: petName,
        appearance: PetAppearance(
          colorIndex: draft.colorIndex,
          earsIndex: draft.earsIndex,
          patternIndex: draft.patternIndex,
        ),
      ),
      createdAt: DateTime.now().toUtc(),
    );

    await ref.read(profileRepositoryProvider).save(profile);
    state = profile;
  }

  Future<void> deleteProfile() async {
    await ref.read(profileRepositoryProvider).delete();
    state = null;
  }
}

final localProfileProvider =
    NotifierProvider<LocalProfileNotifier, PlayerProfile?>(
      LocalProfileNotifier.new,
    );
