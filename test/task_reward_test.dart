import 'package:finny/features/game/application/game_state_provider.dart';
import 'package:finny/features/game/domain/game_goal.dart';
import 'package:finny/features/game/domain/game_state.dart';
import 'package:finny/features/game/domain/game_state_repository.dart';
import 'package:finny/features/tasks/presentation/financial_task_screen.dart';
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

void main() {
  testWidgets('successful task shows source and amount of one-time reward', (
    tester,
  ) async {
    const game = GameState(
      balance: 100,
      savings: 0,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
    );
    final repository = _FakeGameRepository(game);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(game),
        ],
        child: const MaterialApp(
          home: FinancialTaskScreen(taskId: 'payment_snack'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Купить воду за 15'));
    await tester.pumpAndSettle();

    expect(
      find.text('Награда за задание «Перекус перед дорогой»: +10 монет'),
      findsOneWidget,
    );
    expect(repository.state!.balance, 110);
    expect(repository.state!.hasCompletedTask('payment_snack'), isTrue);
    expect(repository.state!.hasReceivedTaskReward('payment_snack'), isTrue);

    await tester.tap(find.text('Купить воду за 15'));
    await tester.pumpAndSettle();

    expect(
      find.text('Задание уже пройдено. Награда за него уже получена.'),
      findsOneWidget,
    );
    expect(repository.state!.balance, 110);
  });

  testWidgets('completed task reward hint fits a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const game = GameState(
      balance: 100,
      savings: 0,
      selectedGoal: GameGoal.explorerCorner,
      currentPeriod: 1,
      totalPeriods: 5,
      periodStatus: PeriodStatus.planned,
      completedTaskIds: ['payment_snack'],
    );
    final repository = _FakeGameRepository(game);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateRepositoryProvider.overrideWithValue(repository),
          initialGameStateProvider.overrideWithValue(game),
        ],
        child: const MaterialApp(
          home: FinancialTaskScreen(taskId: 'payment_snack'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Награда доступна: пройди успешно ещё раз'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
