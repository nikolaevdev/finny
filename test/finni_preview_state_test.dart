import 'package:finny/core/widgets/finni_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Finni preview shows development stage badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinniPreview(
            label: 'Финни',
            mood: 85,
            developmentStage: 2,
          ),
        ),
      ),
    );

    expect(find.text('Финни'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.sentiment_very_satisfied_rounded), findsOneWidget);
  });
}
