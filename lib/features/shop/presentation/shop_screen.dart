import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/game_state.dart';
import '../data/shop_catalog.dart';
import '../domain/shop_item.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopCategory? _filter;
  bool _isWorking = false;

  Future<void> _openPurchase(ShopItem item) async {
    final game = ref.read(gameStateProvider);
    if (game == null) return;

    if (!item.repeatable && game.ownsItem(item.id)) {
      _showMessage('Этот предмет уже куплен.');
      return;
    }

    if (game.balance < item.price) {
      await _showInsufficientFunds(item, game.balance);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogRow(label: 'Цена', value: '${item.price} монет'),
              _DialogRow(
                label: 'Категория',
                value: _categoryTitle(item.category),
              ),
              _DialogRow(label: 'Влияние', value: item.effectLabel),
              const SizedBox(height: AppSpacing.md),
              Text(
                'После покупки останется ${game.balance - item.price} монет.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Купить'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      final result = await ref.read(gameStateProvider.notifier).purchase(item);
      if (!mounted) return;

      switch (result) {
        case PurchaseResult.success:
          final updated = ref.read(gameStateProvider);
          _showMessage(
            'Покупка сохранена. Осталось ${updated?.balance ?? 0} монет. ${item.effectLabel}.',
          );
          break;
        case PurchaseResult.insufficientFunds:
          final currentBalance = ref.read(gameStateProvider)?.balance ?? 0;
          await _showInsufficientFunds(item, currentBalance);
          break;
        case PurchaseResult.alreadyPurchased:
          _showMessage('Этот предмет уже куплен.');
          break;
        case PurchaseResult.periodNotReady:
          _showMessage('Сначала составь и подтверди план на период.');
          break;
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Не удалось сохранить покупку. Попробуй ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _showInsufficientFunds(ShopItem item, int balance) async {
    final missing = (item.price - balance).clamp(0, item.price).toInt();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Монет не хватает'),
          content: Text(
            'Для покупки «${item.title}» не хватает $missing монет. '
            'Можно выбрать товар дешевле или отложить покупку.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отложить'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Выбрать дешевле'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Магазин Финни'),
      ),
      body: SafeArea(
        top: false,
        child: game == null
            ? const Center(child: Text('Игровое состояние не найдено.'))
            : !game.budgetConfirmed
                ? _PlanRequiredContent(game: game)
                : _ShopContent(
                    game: game,
                    filter: _filter,
                    isWorking: _isWorking,
                    onFilterChanged: (value) {
                      setState(() => _filter = value);
                    },
                    onBuy: _openPurchase,
                  ),
      ),
    );
  }
}

class _PlanRequiredContent extends StatelessWidget {
  const _PlanRequiredContent({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fact_check_outlined,
            size: 72,
            color: AppColors.purple,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Сначала составь план',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            game.periodStarted
                ? 'План на этот период ещё не подтверждён.'
                : 'Перед покупками нужно начать период и распределить монеты.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FinniButton(
            text: 'Открыть план',
            onPressed: () => context.push(AppRoutes.budget),
          ),
        ],
      ),
    );
  }
}

class _ShopContent extends StatelessWidget {
  const _ShopContent({
    required this.game,
    required this.filter,
    required this.isWorking,
    required this.onFilterChanged,
    required this.onBuy,
  });

  final GameState game;
  final ShopCategory? filter;
  final bool isWorking;
  final ValueChanged<ShopCategory?> onFilterChanged;
  final ValueChanged<ShopItem> onBuy;

  @override
  Widget build(BuildContext context) {
    final items = ShopCatalog.items.where((item) {
      return filter == null || item.category == filter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShopSummary(game: game),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('Все'),
                selected: filter == null,
                onSelected: (_) => onFilterChanged(null),
              ),
              ChoiceChip(
                label: const Text('Нужно'),
                selected: filter == ShopCategory.need,
                onSelected: (_) => onFilterChanged(ShopCategory.need),
              ),
              ChoiceChip(
                label: const Text('Хочу'),
                selected: filter == ShopCategory.want,
                onSelected: (_) => onFilterChanged(ShopCategory.want),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              mainAxisExtent: 236,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final purchased = !item.repeatable && game.ownsItem(item.id);
              return _ShopItemCard(
                item: item,
                purchased: purchased,
                disabled: isWorking,
                onTap: () => onBuy(item),
              );
            },
          ),
          if (game.purchases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Покупки периода',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ...game.purchases.reversed.map(
              (purchase) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FinniCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        purchase.category == ShopCategory.need
                            ? Icons.favorite_outline_rounded
                            : Icons.sentiment_satisfied_alt_rounded,
                        color: _categoryColor(purchase.category),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          purchase.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '−${purchase.price}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShopSummary extends StatelessWidget {
  const _ShopSummary({required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.gold,
                size: 30,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${game.balance} монет',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                'Период ${game.currentPeriod} из ${game.totalPeriods}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ActualValue(
                  title: 'Нужно',
                  actual: game.budgetActuals.needSpent,
                  planned: game.budgetPlan.need,
                  color: AppColors.need,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ActualValue(
                  title: 'Хочу',
                  actual: game.budgetActuals.wantSpent,
                  planned: game.budgetPlan.want,
                  color: AppColors.want,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActualValue extends StatelessWidget {
  const _ActualValue({
    required this.title,
    required this.actual,
    required this.planned,
    required this.color,
  });

  final String title;
  final int actual;
  final int planned;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Факт $actual / план $planned',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.purchased,
    required this.disabled,
    required this.onTap,
  });

  final ShopItem item;
  final bool purchased;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(item.category);

    return FinniCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                _categoryTitle(item.category),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Icon(
            _itemIcon(item.id),
            size: 42,
            color: color,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            item.effectLabel,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: AppColors.gold,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${item.price}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: disabled || purchased ? null : onTap,
                child: Text(purchased ? 'Куплено' : 'Купить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

String _categoryTitle(ShopCategory category) {
  return switch (category) {
    ShopCategory.need => 'Нужно',
    ShopCategory.want => 'Хочу',
  };
}

Color _categoryColor(ShopCategory category) {
  return switch (category) {
    ShopCategory.need => AppColors.need,
    ShopCategory.want => AppColors.want,
  };
}

IconData _itemIcon(String itemId) {
  return switch (itemId) {
    'food_set' => Icons.restaurant_rounded,
    'fresh_water' => Icons.water_drop_rounded,
    'grooming' => Icons.brush_rounded,
    'sleep_place' => Icons.bed_rounded,
    'ball' => Icons.sports_soccer_rounded,
    'bandana' => Icons.checkroom_rounded,
    'plant' => Icons.local_florist_rounded,
    'star_lamp' => Icons.lightbulb_rounded,
    _ => Icons.shopping_bag_outlined,
  };
}
