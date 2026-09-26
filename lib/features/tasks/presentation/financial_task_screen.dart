import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/widgets/finni_button.dart';
import '../../../core/widgets/finni_card.dart';
import '../../game/application/game_state_provider.dart';
import '../../game/domain/budget_plan.dart';
import '../data/financial_task_catalog.dart';
import '../domain/financial_task.dart';

class FinancialTaskScreen extends ConsumerStatefulWidget {
  const FinancialTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<FinancialTaskScreen> createState() => _FinancialTaskScreenState();
}

class _FinancialTaskScreenState extends ConsumerState<FinancialTaskScreen> {
  static const _step = 10;

  BudgetPlan _allocation = const BudgetPlan();
  int _savingsAmount = 0;
  FinancialTaskResult? _result;
  FinancialTaskAction? _selectedAction;
  bool _saving = false;

  Future<void> _finish(FinancialTask task, FinancialTaskResult result) async {
    if (result.isSuccessful && !_saving) {
      setState(() => _saving = true);
      try {
        await ref.read(gameStateProvider.notifier).completeTask(task.id);
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
    if (mounted) setState(() => _result = result);
  }

  void _changeAllocation(
    FinancialTask task,
    BudgetCategory category,
    int delta,
  ) {
    final next = _allocation.change(
      category: category,
      delta: delta,
      available: task.totalCoins,
    );
    if (!identical(next, _allocation)) {
      setState(() {
        _allocation = next;
        _result = null;
      });
    }
  }

  void _changeSavings(FinancialTask task, int delta) {
    setState(() {
      _savingsAmount = (_savingsAmount + delta).clamp(0, task.totalCoins).toInt();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = FinancialTaskCatalog.byId(widget.taskId);
    final game = ref.watch(gameStateProvider);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Это задание сейчас недоступно. Вернись к списку и выбери другое.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final completed = game?.hasCompletedTask(task.id) == true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Назад',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(task.title),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TaskIntro(task: task, completed: completed),
              const SizedBox(height: AppSpacing.xl),
              switch (task.kind) {
                FinancialTaskKind.allocation => _buildAllocation(task),
                FinancialTaskKind.savingsAmount => _buildSavings(task),
                FinancialTaskKind.action => _buildActions(task),
              },
              if (_result != null) ...[
                const SizedBox(height: AppSpacing.xl),
                _ResultCard(
                  result: _result!,
                  task: task,
                  allocation: _allocation,
                  savingsAmount: _savingsAmount,
                  selectedAction: _selectedAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllocation(FinancialTask task) {
    final remaining = task.totalCoins - _allocation.allocated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinniCard(
          child: Column(
            children: [
              _SummaryRow(label: 'Доступно', value: '${task.totalCoins} монет'),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(label: 'Распределено', value: '${_allocation.allocated} монет'),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(label: 'Осталось', value: '$remaining монет'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AmountControl(
          title: 'Нужно',
          subtitle: 'Обязательные расходы',
          amount: _allocation.need,
          color: AppColors.need,
          onMinus: _allocation.need > 0
              ? () => _changeAllocation(task, BudgetCategory.need, -_step)
              : null,
          onPlus: remaining >= _step
              ? () => _changeAllocation(task, BudgetCategory.need, _step)
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        _AmountControl(
          title: 'Хочу',
          subtitle: 'Необязательные покупки',
          amount: _allocation.want,
          color: AppColors.want,
          onMinus: _allocation.want > 0
              ? () => _changeAllocation(task, BudgetCategory.want, -_step)
              : null,
          onPlus: remaining >= _step
              ? () => _changeAllocation(task, BudgetCategory.want, _step)
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        _AmountControl(
          title: 'Коплю',
          subtitle: 'Монеты для будущей цели',
          amount: _allocation.save,
          color: AppColors.save,
          onMinus: _allocation.save > 0
              ? () => _changeAllocation(task, BudgetCategory.save, -_step)
              : null,
          onPlus: remaining >= _step
              ? () => _changeAllocation(task, BudgetCategory.save, _step)
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        FinniButton(
          text: remaining == 0 ? 'Проверить решение' : 'Распредели ещё $remaining',
          onPressed: remaining == 0 && !_saving
              ? () => _finish(task, task.evaluateAllocation(_allocation))
              : null,
        ),
      ],
    );
  }

  Widget _buildSavings(FinancialTask task) {
    final left = task.totalCoins - _savingsAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinniCard(
          child: Column(
            children: [
              _SummaryRow(label: 'Получено', value: '${task.totalCoins} монет'),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(label: 'В накопления', value: '$_savingsAmount монет'),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(label: 'Останется доступно', value: '$left монет'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _AmountControl(
          title: 'Сколько отложить?',
          subtitle: 'Меняй сумму и следи, сколько останется',
          amount: _savingsAmount,
          color: AppColors.save,
          onMinus: _savingsAmount > 0 ? () => _changeSavings(task, -_step) : null,
          onPlus: _savingsAmount < task.totalCoins ? () => _changeSavings(task, _step) : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        FinniButton(
          text: 'Проверить решение',
          onPressed: !_saving
              ? () => _finish(task, task.evaluateSavingsAmount(_savingsAmount))
              : null,
        ),
      ],
    );
  }

  Widget _buildActions(FinancialTask task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final action in task.actions) ...[
          FinniCard(
            onTap: _saving
                ? null
                : () {
                    setState(() => _selectedAction = action);
                    _finish(task, task.evaluateAction(action));
                  },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.touch_app_outlined, color: AppColors.purple),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(action.description),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _TaskIntro extends StatelessWidget {
  const _TaskIntro({required this.task, required this.completed});

  final FinancialTask task;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(task.topic.title, style: Theme.of(context).textTheme.labelLarge),
              ),
              if (completed)
                const Icon(Icons.check_circle_rounded, color: AppColors.success),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(task.story, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          Text(task.instruction, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AmountControl extends StatelessWidget {
  const _AmountControl({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final String subtitle;
  final int amount;
  final Color color;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('minus-$title'),
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          SizedBox(
            width: 58,
            child: Text(
              '$amount',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            key: ValueKey('plus-$title'),
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.task,
    required this.allocation,
    required this.savingsAmount,
    required this.selectedAction,
  });

  final FinancialTaskResult result;
  final FinancialTask task;
  final BudgetPlan allocation;
  final int savingsAmount;
  final FinancialTaskAction? selectedAction;

  @override
  Widget build(BuildContext context) {
    return FinniCard(
      color: result.isSuccessful
          ? AppColors.success.withValues(alpha: 0.10)
          : AppColors.save.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isSuccessful ? Icons.check_circle_rounded : Icons.lightbulb_outline_rounded,
                color: result.isSuccessful ? AppColors.success : AppColors.save,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(result.title, style: Theme.of(context).textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (task.kind == FinancialTaskKind.allocation)
            Text('Твой план: нужно ${allocation.need}, хочу ${allocation.want}, коплю ${allocation.save} монет.'),
          if (task.kind == FinancialTaskKind.savingsAmount)
            Text('Ты выбрал $savingsAmount монет в накопления. Останется ${task.totalCoins - savingsAmount}.'),
          if (task.kind == FinancialTaskKind.action && selectedAction != null)
            _ActionConsequences(action: selectedAction!),
          const SizedBox(height: AppSpacing.md),
          Text(result.explanation),
          const SizedBox(height: AppSpacing.md),
          Text(
            result.nextStep,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ActionConsequences extends StatelessWidget {
  const _ActionConsequences({required this.action});

  final FinancialTaskAction action;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (action.balanceDelta != 0) parts.add('баланс ${_signed(action.balanceDelta)}');
    if (action.savingsDelta != 0) parts.add('накопления ${_signed(action.savingsDelta)}');
    if (action.careDelta != 0) parts.add('забота ${_signed(action.careDelta)}');
    if (action.moodDelta != 0) parts.add('настроение ${_signed(action.moodDelta)}');

    return Text('Последствия: ${parts.join(', ')}.');
  }

  String _signed(int value) => value > 0 ? '+$value' : '$value';
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
