import 'package:finny/core/widgets/finni_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Finni preview maps stage, appearance and mood to assets', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FinniPreview(
              label: 'Финни',
              colorIndex: 1,
              earsIndex: 1,
              patternIndex: 2,
              mood: 20,
              developmentStage: 1,
            ),
          ),
        ),
      ),
    );

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName)
        .toSet();

    expect(assetNames, contains('assets/images/finni/stage/growing_sand.png'));
    expect(assetNames, contains('assets/images/finni/mood/quiet.png'));
    expect(assetNames, contains('assets/images/finni/traits/ears/rounded.png'));
    expect(
      assetNames,
      contains('assets/images/finni/traits/patterns/stripes.png'),
    );
    expect(find.text('Финни'), findsOneWidget);
    expect(find.text('Подрос'), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsNothing);
  });

  testWidgets('Finni preview clamps saved appearance indexes safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinniPreview(
            colorIndex: 99,
            earsIndex: -4,
            patternIndex: 12,
            developmentStage: 7,
          ),
        ),
      ),
    );

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .whereType<AssetImage>()
        .map((image) => image.assetName)
        .toSet();

    expect(
      assetNames,
      contains('assets/images/finni/stage/confident_lavender.png'),
    );
    expect(assetNames, contains('assets/images/finni/traits/ears/pointed.png'));
    expect(
      assetNames,
      contains('assets/images/finni/traits/patterns/stripes.png'),
    );
  });
}
