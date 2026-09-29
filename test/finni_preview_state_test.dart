import 'package:finny/core/widgets/finni_preview.dart';
import 'package:finny/core/widgets/finni_character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


String? _assetName(ImageProvider<Object> provider) {
  if (provider is AssetImage) return provider.assetName;
  if (provider is ResizeImage) {
    final inner = provider.imageProvider;
    if (inner is AssetImage) return inner.assetName;
  }
  return null;
}

void main() {
  testWidgets('Finni preview displays the selected color and growth stage',
      (tester) async {
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
        .map((image) => _assetName(image.image))
        .whereType<String>()
        .toSet();

    expect(
      assetNames,
      contains('assets/images/finni/mood_sprite/growing_sand_rounded_stripes_quiet.webp'),
    );
    // The large preview uses the same completed sprite as the home scene.
    expect(assetNames, contains('assets/images/finni/mood_portrait/sand_quiet.webp'));
    expect(assetNames, hasLength(2));
    final character = tester.widget<FinniCharacter>(find.byType(FinniCharacter));
    expect(character.earsIndex, 1);
    expect(character.patternIndex, 2);
    expect(character.animate, isFalse);
    expect(character.tapReaction, isFalse);
    expect(find.text('Финни'), findsOneWidget);
    expect(find.text('Подрос · округлые · полосы'), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsNothing);
  });

  testWidgets('Finni preview clamps saved appearance indexes safely',
      (tester) async {
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
        .map((image) => _assetName(image.image))
        .whereType<String>()
        .toSet();

    expect(
      assetNames,
      contains('assets/images/finni/mood_sprite/confident_lavender_pointed_stripes_happy.webp'),
    );
    expect(assetNames, contains('assets/images/finni/mood_portrait/lavender_happy.webp'));
    expect(assetNames, hasLength(2));
  });

  testWidgets('all ear and marking choices paint on each growth stage',
      (tester) async {
    for (var stage = 0; stage < 3; stage++) {
      for (var ears = 0; ears < 3; ears++) {
        for (var pattern = 0; pattern < 3; pattern++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: FinniCharacter(
                    size: 180,
                    colorIndex: stage,
                    developmentStage: stage,
                    earsIndex: ears,
                    patternIndex: pattern,
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull,
              reason: 'stage=$stage ears=$ears pattern=$pattern');
        }
      }
    }
  });
}
