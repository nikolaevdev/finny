import 'package:finny/features/adult/presentation/adult_screen.dart';
import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/pet/domain/pet.dart';
import 'package:finny/features/pet/domain/pet_appearance.dart';
import 'package:finny/features/profile/application/local_profile_provider.dart';
import 'package:finny/features/profile/domain/player_profile.dart';
import 'package:finny/features/profile/domain/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGameRepository implements GameStateRepository {
  _FakeGameRepository(this.state);

  GameState? state;

  @override
  Future<void> delete() async => state = null;

  @override
  GameState? load() => state;

  @override
  Future<void> save(GameState state) async => this.state = state;
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  PlayerProfile? profile;

  @override
  Future<void> delete() async => profile = null;

  @override
  PlayerProfile? load() => profile;

  @override
  Future<void> save(PlayerProfile profile) async => this.profile = profile;
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  final scrollable = find.byType(Scrollable).first;

  for (var attempt = 0; attempt < 20; attempt++) {
    final target = find.text(text);
    if (target.evaluate().isNotEmpty) {
      await tester.ensureVisible(target.first);
      await tester.pumpAndSettle();
      return;
    }

    await tester.drag(scrollable, const Offset(0, -260));
    await tester.pumpAndSettle();
  }

  fail('Не удалось найти текст после прокрутки: $text');
}

void main() {
  testWidgets('demo profile can be reset after confirmation', (tester) async {
    final profile = PlayerProfile(
      playerName: 'Эксперт',
      demoMode: true,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(colorIndex: 0, earsIndex: 0, patternIndex: 0),
      ),
      createdAt: DateTime.utc(2026, 9, 26),
    );
    const progressed = GameState(
      balance: 435,
      savings: 130,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 5,
      totalPeriods: 5,
      periodStatus: PeriodStatus.completed,
      completedTaskIds: ['budget_weekend', 'savings_gift'],
    );
    final gameRepository = _FakeGameRepository(progressed);
    final profileRepository = _FakeProfileRepository(profile);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(gameRepository),
          initialGameStateProvider.overrideWithValue(progressed),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          initialProfileProvider.overrideWithValue(profile),
        ],
        child: const MaterialApp(home: AdultScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Зачем нужен Финни'), findsOneWidget);

    await _scrollToText(tester, 'Сбросить демо-прогресс');

    final demoResetText = find.text('Сбросить демо-прогресс');
    final demoResetTile = find.ancestor(
      of: demoResetText,
      matching: find.byType(ListTile),
    );

    expect(find.text('Демонстрационный режим'), findsOneWidget);
    expect(demoResetTile, findsOneWidget);
    expect(find.text('Удалить профиль и данные'), findsOneWidget);
    await tester.tap(demoResetTile);
    await tester.pumpAndSettle();

    expect(find.text('Сбросить демо-прогресс?'), findsOneWidget);
    expect(gameRepository.state!.balance, 435);

    await tester.tap(find.widgetWithText(FilledButton, 'Сбросить'));
    await tester.pumpAndSettle();

    expect(gameRepository.state!.currentPeriod, 1);
    expect(gameRepository.state!.periodStatus, PeriodStatus.notStarted);
    expect(gameRepository.state!.balance, 0);
    expect(gameRepository.state!.savings, 120);
    expect(gameRepository.state!.completedTaskIds, isEmpty);
  });

  testWidgets('ordinary profile reset is available only in adult section', (
    tester,
  ) async {
    final profile = PlayerProfile(
      playerName: 'Игрок',
      demoMode: false,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(colorIndex: 0, earsIndex: 0, patternIndex: 0),
      ),
      createdAt: DateTime.utc(2026, 9, 27),
    );
    const progressed = GameState(
      balance: 90,
      savings: 40,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 2,
      totalPeriods: 5,
      periodStatus: PeriodStatus.notStarted,
      completedTaskIds: ['budget_weekend'],
      rewardedTaskIds: ['budget_weekend'],
    );
    final gameRepository = _FakeGameRepository(progressed);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(gameRepository),
          initialGameStateProvider.overrideWithValue(progressed),
          initialProfileProvider.overrideWithValue(profile),
        ],
        child: const MaterialApp(home: AdultScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollToText(tester, 'Сбросить игровой прогресс');

    final resetText = find.text('Сбросить игровой прогресс');
    final resetTile = find.ancestor(
      of: resetText,
      matching: find.byType(ListTile),
    );

    expect(resetTile, findsOneWidget);
    expect(find.text('Удалить профиль и данные'), findsOneWidget);

    await tester.tap(resetTile);
    await tester.pumpAndSettle();
    expect(find.text('Сбросить игровой прогресс?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Сбросить'));
    await tester.pumpAndSettle();

    expect(gameRepository.state!.balance, 0);
    expect(gameRepository.state!.savings, 0);
    expect(gameRepository.state!.completedTaskIds, isEmpty);
    expect(gameRepository.state!.rewardedTaskIds, isEmpty);
  });
}
