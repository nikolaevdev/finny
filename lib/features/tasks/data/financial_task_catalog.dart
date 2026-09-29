import '../domain/financial_task.dart';

abstract final class FinancialTaskCatalog {
  static const tasks = <FinancialTask>[
    FinancialTask(
      id: 'budget_weekend',
      title: 'Выходные Финни',
      topic: FinancialTaskTopic.budgetPlanning,
      kind: FinancialTaskKind.allocation,
      story: 'У Финни есть 90 монет на выходные. Нужно купить еду за 40 монет, а ещё хочется развлечений и немного отложить.',
      instruction: 'Распредели все 90 монет между «Нужно», «Хочу» и «Коплю». На обязательное оставь не меньше 40, а в накопления – не меньше 10.',
      totalCoins: 90,
      minimumNeed: 40,
      minimumSavings: 10,
      successExplanation: 'Сначала обеспечены обязательные расходы, часть монет сохранена, а оставшееся можно потратить на желания.',
      retryExplanation: 'Проверь, хватает ли на еду и осталось ли хотя бы немного на накопления. Хороший бюджет учитывает и сегодняшний день, и будущую цель.',
      nextStep: 'Попробуй перенести этот принцип в план текущего игрового периода.',
    ),
    FinancialTask(
      id: 'budget_school_fair',
      title: 'Ярмарка изобретателей',
      topic: FinancialTaskTopic.budgetPlanning,
      kind: FinancialTaskKind.allocation,
      story: 'Финни получил 120 монет. Для участия в ярмарке нужны материалы за 50 монет. Остальное можно распределить между развлечениями и целью.',
      instruction: 'Распредели все 120 монет. На материалы нужно не меньше 50 монет, а накопить стоит не меньше 20.',
      totalCoins: 120,
      minimumNeed: 50,
      minimumSavings: 20,
      successExplanation: 'Обязательная покупка защищена, накопления растут, и при этом остаётся место для приятных расходов.',
      retryExplanation: 'Если потратить слишком много на желания, может не хватить на материалы или цель. Сначала отдели обязательную часть.',
      nextStep: 'Перед новой покупкой вспоминай, какие траты уже запланированы.',
    ),
    FinancialTask(
      id: 'savings_gift',
      title: 'Монеты в подарок',
      topic: FinancialTaskTopic.savings,
      kind: FinancialTaskKind.savingsAmount,
      story: 'Финни получил в подарок 60 монет. На ближайшие нужды достаточно 30 монет, поэтому часть подарка можно отправить к цели.',
      instruction: 'Выбери, сколько из 60 монет отложить. Разумный диапазон для этой ситуации – от 20 до 30 монет.',
      totalCoins: 60,
      minimumSavings: 20,
      maximumSavings: 30,
      successExplanation: 'Ты сохранил заметную часть подарка и оставил достаточно монет на ближайшие расходы.',
      retryExplanation: 'Слишком маленькая сумма почти не приблизит цель, а слишком большая может оставить Финни без денег на ближайшие нужды.',
      nextStep: 'Регулярные небольшие пополнения тоже помогают большой цели становиться ближе.',
    ),
    FinancialTask(
      id: 'savings_bonus',
      title: 'Небольшой бонус',
      topic: FinancialTaskTopic.savings,
      kind: FinancialTaskKind.savingsAmount,
      story: 'После задания Финни получил бонус 50 монет. На обязательные расходы уже всё отложено, но 20 монет лучше оставить на непредвиденную покупку.',
      instruction: 'Выбери сумму накопления. В этой ситуации можно спокойно отложить от 20 до 30 монет.',
      totalCoins: 50,
      minimumSavings: 20,
      maximumSavings: 30,
      successExplanation: 'Часть бонуса работает на цель, а часть остаётся доступной на случай неожиданной траты.',
      retryExplanation: 'Хорошие накопления не требуют отправлять в копилку вообще все свободные деньги. Полезно оставлять небольшой запас.',
      nextStep: 'Посмотри на свою цель и реши, какую сумму удобно добавлять регулярно.',
    ),
    FinancialTask(
      id: 'payment_snack',
      title: 'Перекус перед дорогой',
      topic: FinancialTaskTopic.payments,
      kind: FinancialTaskKind.action,
      story: 'У Финни 35 монет. Перед долгой дорогой ему нужна вода за 15 монет. Рядом продаётся большая сладость за 30 монет.',
      instruction: 'Выбери действие и посмотри, что произойдёт с оставшимися монетами и состоянием Финни.',
      actions: [
        FinancialTaskAction(
          id: 'water',
          title: 'Купить воду за 15',
          description: 'Останется 20 монет, а важная потребность будет закрыта.',
          feedback: 'Сначала оплачена нужная вещь. После покупки остаются монеты на другие решения.',
          isRecommended: true,
          balanceDelta: -15,
          careDelta: 8,
        ),
        FinancialTaskAction(
          id: 'sweet',
          title: 'Купить сладость за 30',
          description: 'Останется 5 монет, а вода всё ещё будет нужна.',
          feedback: 'Почти весь бюджет ушёл на желание, а обязательная покупка осталась. Сначала лучше закрыть нужную трату.',
          isRecommended: false,
          balanceDelta: -30,
          moodDelta: 5,
        ),
      ],
      successExplanation: '',
      retryExplanation: '',
      nextStep: 'Перед оплатой проверь: это обязательная покупка или желание, и что останется после неё.',
    ),
    FinancialTask(
      id: 'payment_sale',
      title: 'Скидка или цель',
      topic: FinancialTaskTopic.payments,
      kind: FinancialTaskKind.action,
      story: 'У Финни 70 монет и уже выбрана финансовая цель. В магазине появилась игрушка со скидкой за 50 монет.',
      instruction: 'Реши, что сделать с деньгами сейчас. Скидка сама по себе ещё не означает, что покупка нужна.',
      actions: [
        FinancialTaskAction(
          id: 'buy',
          title: 'Купить игрушку за 50',
          description: 'На балансе останется 20 монет.',
          feedback: 'Цена стала ниже, но покупка всё равно забрала большую часть денег. Если игрушка не была в плане, скидка не делает её обязательной.',
          isRecommended: false,
          balanceDelta: -50,
          moodDelta: 6,
        ),
        FinancialTaskAction(
          id: 'save',
          title: 'Отложить 30 к цели',
          description: 'В накопления уйдёт 30 монет, а 40 останется доступно.',
          feedback: 'Ты сравнил желание с выбранной целью и сохранил часть денег. При этом на балансе остался запас.',
          isRecommended: true,
          balanceDelta: -30,
          savingsDelta: 30,
        ),
      ],
      successExplanation: '',
      retryExplanation: '',
      nextStep: 'Перед покупкой со скидкой спроси себя, хотел бы ты эту вещь и без слова «скидка».',
    ),
  ];

  static FinancialTask? byId(String id) {
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  static List<FinancialTask> byTopic(FinancialTaskTopic topic) =>
      tasks.where((task) => task.topic == topic).toList(growable: false);

  static FinancialTask? firstIncomplete(Iterable<String> completedTaskIds) {
    final completed = completedTaskIds.toSet();
    for (final task in tasks) {
      if (!completed.contains(task.id)) return task;
    }
    return null;
  }
}
