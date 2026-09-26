import 'package:finny/features/settings/data/shared_preferences_app_settings_repository.dart';
import 'package:finny/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('app settings use defaults and persist changes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesAppSettingsRepository(preferences);

    final initial = repository.load();
    expect(initial.soundEnabled, isTrue);
    expect(initial.animationsEnabled, isTrue);

    await repository.save(
      const AppSettings(soundEnabled: false, animationsEnabled: false),
    );

    final restored = repository.load();
    expect(restored.soundEnabled, isFalse);
    expect(restored.animationsEnabled, isFalse);
  });
}
