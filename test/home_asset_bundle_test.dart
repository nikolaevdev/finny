import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every Finny appearance and visual emotion is bundled',
      () async {
    for (final stage in ['little', 'growing', 'confident']) {
      for (final color in ['turquoise', 'sand', 'lavender']) {
        for (final ears in ['pointed', 'rounded', 'floppy']) {
          for (final pattern in ['natural', 'spots', 'stripes']) {
            for (final emotion in ['quiet', 'calm', 'happy', 'delighted']) {
              final path =
                  'assets/images/finni/mood_sprite/${stage}_${color}_${ears}_${pattern}_$emotion.webp';
              expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0),
                  reason: path);
            }
          }
        }
      }
    }

    for (final color in ['turquoise', 'sand', 'lavender']) {
      for (final mood in ['quiet', 'calm', 'happy', 'delighted']) {
        final path =
            'assets/images/finni/mood_portrait/${color}_$mood.webp';
        expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0),
            reason: path);
      }
    }
  });
}
