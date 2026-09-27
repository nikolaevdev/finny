import 'package:finny/features/settings/application/app_settings_provider.dart';
import 'package:finny/features/settings/domain/app_settings.dart';
import 'package:finny/features/settings/domain/app_settings_repository.dart';
import 'package:finny/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSettingsRepository implements AppSettingsRepository {
  AppSettings value = const AppSettings();

  @override
  AppSettings load() => value;

  @override
  Future<void> save(AppSettings settings) async => value = settings;
}

void main() {
  testWidgets('sound setting is persisted', (tester) async {
    final settingsRepository = _FakeSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(settingsRepository),
          initialAppSettingsProvider.overrideWithValue(const AppSettings()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    await tester.tap(find.text('Звуки интерфейса'));
    await tester.pumpAndSettle();

    expect(settingsRepository.value.soundEnabled, isFalse);
  });

  testWidgets('destructive profile actions are not exposed in child settings', (
    tester,
  ) async {
    final settingsRepository = _FakeSettingsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsRepositoryProvider.overrideWithValue(settingsRepository),
          initialAppSettingsProvider.overrideWithValue(const AppSettings()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Сбросить игровой прогресс'), findsNothing);
    expect(find.text('Удалить профиль и данные'), findsNothing);
    await tester.scrollUntilVisible(
      find.text(
        'Сброс и удаление профиля доступны в защищённом разделе «Для взрослого».',
      ),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.text(
        'Сброс и удаление профиля доступны в защищённом разделе «Для взрослого».',
      ),
      findsOneWidget,
    );
  });
}
