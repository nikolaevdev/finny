import 'package:finny/app/theme/app_colors.dart';
import 'package:finny/app/theme/app_theme.dart';
import 'package:finny/core/widgets/finni_button.dart';
import 'package:finny/core/widgets/finni_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('design system exposes the approved visual foundation', (
    tester,
  ) async {
    late ThemeData theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            theme = Theme.of(context);
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );

    expect(theme.scaffoldBackgroundColor, Colors.transparent);
    expect(theme.colorScheme.primary, AppColors.purple);
    expect(theme.textTheme.displaySmall?.fontSize, 32);
    expect(theme.textTheme.headlineLarge?.fontSize, 28);
    expect(theme.textTheme.bodyMedium?.fontSize, 16);
    expect(theme.textTheme.labelSmall?.fontSize, 13);
    expect(theme.appBarTheme.toolbarHeight, 64);
  });

  testWidgets('FinniButton keeps a large touch target for long labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: FinniButton(
                text: 'Продолжить финансовое приключение',
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final buttonSize = tester.getSize(find.byType(FilledButton));
    expect(buttonSize.height, greaterThanOrEqualTo(56));
    expect(find.text('Продолжить финансовое приключение'), findsOneWidget);
  });

  testWidgets('FinniProgressBar normalizes values and exposes semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: FinniProgressBar(
            value: 1.4,
            semanticLabel: 'Прогресс цели',
          ),
        ),
      ),
    );

    final indicator = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(indicator.value, 1);

    final semantics = tester.getSemantics(
      find.bySemanticsLabel('Прогресс цели'),
    );
    expect(semantics.value, contains('100%'));
  });
}
