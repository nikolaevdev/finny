import 'package:flutter/foundation.dart';

import '../../game/domain/budget_plan.dart';

enum FinancialTaskTopic { budgetPlanning, savings, payments }

enum FinancialTaskKind { allocation, savingsAmount, action }

extension FinancialTaskTopicText on FinancialTaskTopic {
  String get title => switch (this) {
        FinancialTaskTopic.budgetPlanning => 'Планирование бюджета',
        FinancialTaskTopic.savings => 'Сбережения',
        FinancialTaskTopic.payments => 'Платежи и покупки',
      };
}

@immutable
class FinancialTaskAction {
  const FinancialTaskAction({
    required this.id,
    required this.title,
    required this.description,
    required this.feedback,
    required this.isRecommended,
    this.balanceDelta = 0,
    this.savingsDelta = 0,
    this.careDelta = 0,
    this.moodDelta = 0,
  });

  final String id;
  final String title;
  final String description;
  final String feedback;
  final bool isRecommended;
  final int balanceDelta;
  final int savingsDelta;
  final int careDelta;
  final int moodDelta;
}

@immutable
class FinancialTaskResult {
  const FinancialTaskResult({
    required this.isSuccessful,
    required this.title,
    required this.explanation,
    required this.nextStep,
  });

  final bool isSuccessful;
  final String title;
  final String explanation;
  final String nextStep;
}

@immutable
class FinancialTask {
  const FinancialTask({
    required this.id,
    required this.title,
    required this.topic,
    required this.kind,
    required this.story,
    required this.instruction,
    required this.successExplanation,
    required this.retryExplanation,
    required this.nextStep,
    this.totalCoins = 0,
    this.minimumNeed = 0,
    this.minimumSavings = 0,
    this.maximumSavings,
    this.actions = const [],
  });

  final String id;
  final String title;
  final FinancialTaskTopic topic;
  final FinancialTaskKind kind;
  final String story;
  final String instruction;
  final String successExplanation;
  final String retryExplanation;
  final String nextStep;
  final int totalCoins;
  final int minimumNeed;
  final int minimumSavings;
  final int? maximumSavings;
  final List<FinancialTaskAction> actions;

  FinancialTaskResult evaluateAllocation(BudgetPlan plan) {
    final fullyAllocated = plan.allocated == totalCoins;
    final needCovered = plan.need >= minimumNeed;
    final savingsCovered = plan.save >= minimumSavings;
    final successful = fullyAllocated && needCovered && savingsCovered;

    return FinancialTaskResult(
      isSuccessful: successful,
      title: successful ? 'Хороший план' : 'План можно улучшить',
      explanation: successful ? successExplanation : retryExplanation,
      nextStep: nextStep,
    );
  }

  FinancialTaskResult evaluateSavingsAmount(int amount) {
    final maximum = maximumSavings ?? totalCoins;
    final successful = amount >= minimumSavings && amount <= maximum;

    return FinancialTaskResult(
      isSuccessful: successful,
      title: successful ? 'Получилось сбалансированно' : 'Попробуй другой размер',
      explanation: successful ? successExplanation : retryExplanation,
      nextStep: nextStep,
    );
  }

  FinancialTaskResult evaluateAction(FinancialTaskAction action) {
    return FinancialTaskResult(
      isSuccessful: action.isRecommended,
      title: action.isRecommended ? 'Разумное решение' : 'Есть более безопасный вариант',
      explanation: action.feedback,
      nextStep: nextStep,
    );
  }
}
