import '../domain/glossary_term.dart';

abstract final class FinancialGlossary {
  static const terms = <GlossaryTerm>[
    GlossaryTerm(
      title: 'Баланс',
      description: 'Монеты, которыми можно распоряжаться прямо сейчас.',
    ),
    GlossaryTerm(
      title: 'Бюджет',
      description:
          'План, как распределить доступные монеты между разными задачами.',
    ),
    GlossaryTerm(
      title: 'План',
      description: 'Сколько монет заранее решено направить на нужное, желания и накопления.',
    ),
    GlossaryTerm(
      title: 'Факт',
      description:
          'Сколько монет на самом деле было потрачено или отложено за период.',
    ),
    GlossaryTerm(
      title: 'Нужно',
      description: 'Обязательные расходы на важные вещи, без которых Финни будет сложнее.',
    ),
    GlossaryTerm(
      title: 'Хочу',
      description: 'Необязательные приятные покупки, которые можно сделать после важных расходов.',
    ),
    GlossaryTerm(
      title: 'Накопления',
      description:
          'Монеты, которые не тратят сейчас, а откладывают для будущей цели.',
    ),
    GlossaryTerm(
      title: 'Финансовая цель',
      description: 'Понятная покупка или событие, ради которого постепенно собирают нужную сумму.',
    ),
    GlossaryTerm(
      title: 'Игровой период',
      description: 'Один цикл: получить монеты, составить план, принять решения и сравнить план с фактом.',
    ),
  ];
}
