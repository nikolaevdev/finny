import 'package:finny/features/pet/domain/pet.dart';
import 'package:finny/features/pet/domain/pet_appearance.dart';
import 'package:finny/features/profile/data/shared_preferences_profile_repository.dart';
import 'package:finny/features/profile/domain/player_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('local profile is saved and restored', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesProfileRepository(preferences);

    final profile = PlayerProfile(
      playerName: 'Миша',
      demoMode: true,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(colorIndex: 2, earsIndex: 1, patternIndex: 2),
      ),
      createdAt: DateTime.utc(2026, 9, 26),
    );

    await repository.save(profile);
    final restored = repository.load();

    expect(restored, isNotNull);
    expect(restored!.playerName, 'Миша');
    expect(restored.demoMode, isTrue);
    expect(restored.pet.name, 'Финни');
    expect(restored.pet.appearance.colorIndex, 2);
    expect(restored.pet.appearance.earsIndex, 1);
    expect(restored.pet.appearance.patternIndex, 2);
  });
}
