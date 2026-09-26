import 'package:finny/features/progress/data/financial_glossary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('financial glossary contains the core terms used in the game', () {
    final titles = FinancialGlossary.terms.map((term) => term.title).toSet();

    expect(FinancialGlossary.terms.length, greaterThanOrEqualTo(8));
    expect(titles, contains('Баланс'));
    expect(titles, contains('Бюджет'));
    expect(titles, contains('План'));
    expect(titles, contains('Факт'));
    expect(titles, contains('Накопления'));
    expect(titles, contains('Финансовая цель'));
    expect(titles, contains('Игровой период'));
    expect(
      FinancialGlossary.terms.every((term) => term.description.trim().isNotEmpty),
      isTrue,
    );
  });
}
