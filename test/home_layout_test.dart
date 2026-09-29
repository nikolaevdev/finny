import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/home/presentation/home_screen.dart';
import 'package:finny/core/widgets/finni_character.dart';
import 'package:finny/features/pet/domain/pet.dart';
import 'package:finny/features/pet/domain/pet_appearance.dart';
import 'package:finny/features/profile/application/local_profile_provider.dart';
import 'package:finny/features/profile/domain/player_profile.dart';
import 'package:finny/features/shop/domain/purchase_record.dart';
import 'package:finny/features/shop/domain/shop_item.dart';
import 'package:finny/app/theme/app_colors.dart';
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


String? _assetName(ImageProvider<Object> provider) {
  if (provider is AssetImage) return provider.assetName;
  if (provider is ResizeImage) {
    final inner = provider.imageProvider;
    if (inner is AssetImage) return inner.assetName;
  }
  return null;
}

void main() {
  for (final size in [const Size(390, 844), const Size(320, 568)]) {
    testWidgets('home fits $size and keeps game actions accessible', (tester) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const game = GameState(
      balance: 120,
      savings: 20,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      ownedItemIds: ['sleep_place', 'plant', 'star_lamp', 'explorer_journal'],
      purchases: [
        PurchaseRecord(
          itemId: 'ball',
          title: 'Мяч',
          price: 25,
          category: ShopCategory.want,
        ),
      ],
      completedTaskIds: ['budget_weekend'],
      rewardedTaskIds: ['budget_weekend'],
    );
    final profile = PlayerProfile(
      playerName: 'Игрок',
      demoMode: false,
      pet: const Pet(
        name: 'Финни',
        appearance: PetAppearance(colorIndex: 2, earsIndex: 2, patternIndex: 1),
      ),
      createdAt: DateTime.utc(2026, 9, 27),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(_FakeGameRepository(game)),
          initialGameStateProvider.overrideWithValue(game),
          initialProfileProvider.overrideWithValue(profile),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Задания'), findsOneWidget);
    expect(find.text('Магазин'), findsOneWidget);
    expect(find.text('Цель'), findsOneWidget);
    expect(find.text('Забота'), findsOneWidget);
    expect(find.text('Настроение'), findsOneWidget);
    expect(tester.widget<Text>(find.text('60/100')).style?.color,
        AppColors.textPrimary);
    expect(find.text('Прогресс'), findsOneWidget);
    expect(find.text('Для взрослого'), findsOneWidget);
    final finni = tester.widget<FinniCharacter>(find.byType(FinniCharacter));
    expect(finni.colorIndex, 2);
    expect(finni.earsIndex, 2);
    expect(finni.patternIndex, 1);
    expect(finni.animate, isTrue);
    expect(finni.tapReaction, isTrue);
    final imageAssets = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => _assetName(image.image))
        .whereType<String>()
        .toSet();
    expect(imageAssets, containsAll([
      'assets/images/navigation/plan.png',
      'assets/images/navigation/shop.png',
      'assets/images/navigation/tasks.png',
      'assets/images/navigation/goal.png',
      'assets/images/finni/mood_portrait/lavender_happy.webp',
      'assets/images/finni/mood_sprite/little_lavender_floppy_spots_happy.webp',
      'assets/images/shop/items/sleep_place.png',
      'assets/images/shop/items/plant.png',
      'assets/images/shop/items/star_lamp.png',
      'assets/images/shop/items/explorer_journal.png',
      'assets/images/shop/items/ball.png',
    ]));
    expect(tester.takeException(), isNull);
    });
  }
}
