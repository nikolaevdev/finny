import 'package:finny/core/widgets/finni_character.dart';
import 'package:finny/features/game/domain/pet_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all mood thresholds have one visual emotion', () {
    expect(visualEmotionFor(moodLevelFor(0)), FinniVisualEmotion.quiet);
    expect(visualEmotionFor(moodLevelFor(34)), FinniVisualEmotion.quiet);
    expect(visualEmotionFor(moodLevelFor(35)), FinniVisualEmotion.calm);
    expect(visualEmotionFor(moodLevelFor(59)), FinniVisualEmotion.calm);
    expect(visualEmotionFor(moodLevelFor(60)), FinniVisualEmotion.happy);
    expect(visualEmotionFor(moodLevelFor(79)), FinniVisualEmotion.happy);
    expect(visualEmotionFor(moodLevelFor(80)), FinniVisualEmotion.delighted);
    expect(visualEmotionFor(PetMoodLevel.delighted), FinniVisualEmotion.delighted);
  });

  test('delighted selects its own sprite of the same appearance', () {
    expect(
      FinniCharacter.moodSpriteAsset(2, 1, 2, 1, 100),
      'assets/images/finni/mood_sprite/confident_sand_floppy_spots_delighted.webp',
    );
  });

  testWidgets('mood changes replace the completed sprite without a facial mask',
      (tester) async {
    Future<void> show(int mood) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FinniCharacter(
            size: 180,
            developmentStage: 1,
            colorIndex: 2,
            earsIndex: 1,
            patternIndex: 2,
            mood: mood,
            animate: true,
          ),
        ),
      ));
      await tester.pump();
    }

    await show(20);
    expect(find.byType(ShaderMask), findsNothing);
    expect(find.byType(AnimatedSwitcher), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    final first = tester.widget<Image>(find.byType(Image));
    expect(first.image, isA<ResizeImage>());
    expect(
      (first.image as ResizeImage).imageProvider,
      isA<AssetImage>().having(
        (image) => image.assetName,
        'asset',
        'assets/images/finni/mood_sprite/growing_lavender_rounded_stripes_quiet.webp',
      ),
    );

    await show(90);
    expect(find.byType(Image), findsOneWidget);
    final next = tester.widget<Image>(find.byType(Image));
    expect(
      (next.image as ResizeImage).imageProvider,
      isA<AssetImage>().having(
        (image) => image.assetName,
        'asset',
        'assets/images/finni/mood_sprite/growing_lavender_rounded_stripes_delighted.webp',
      ),
    );
  });
}
