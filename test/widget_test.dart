import 'package:finny/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding opens when local profile does not exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FinniApp(prewarmStoryAssets: false),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Привет! Это Финни'), findsOneWidget);
    expect(find.text('Начать'), findsOneWidget);
  });
}
