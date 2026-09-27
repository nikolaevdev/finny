import 'package:finny/app/router.dart';
import 'package:finny/features/adult/presentation/adult_access_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('adult access requires the arithmetic answer', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.adultAccess,
      routes: [
        GoRoute(
          path: AppRoutes.adultAccess,
          builder: (context, state) => const AdultAccessScreen(),
        ),
        GoRoute(
          path: AppRoutes.adult,
          builder: (context, state) =>
              const Scaffold(body: Text('Раздел открыт')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('8 + 7 = ?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '12');
    await tester.tap(find.text('Открыть раздел'));
    await tester.pumpAndSettle();

    expect(find.text('Проверь ответ и попробуй ещё раз.'), findsOneWidget);
    expect(find.text('Раздел открыт'), findsNothing);

    await tester.enterText(find.byType(TextField), '15');
    await tester.tap(find.text('Открыть раздел'));
    await tester.pumpAndSettle();

    expect(find.text('Раздел открыт'), findsOneWidget);
  });
}
