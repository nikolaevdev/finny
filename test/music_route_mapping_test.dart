import 'package:flutter_test/flutter_test.dart';
import 'package:finny/app/router.dart';
import 'package:finny/core/audio/finni_audio.dart';

void main() {
  test('music scenes follow app routes', () {
    expect(musicSceneForRoute(AppRouteNames.home), MusicScene.main);
    expect(musicSceneForRoute(AppRouteNames.pet), MusicScene.main);
    expect(musicSceneForRoute(AppRouteNames.shop), MusicScene.shop);
    expect(musicSceneForRoute(AppRouteNames.periodSummary), MusicScene.shop);
    expect(musicSceneForRoute(AppRouteNames.budget), MusicScene.calm);
    expect(musicSceneForRoute(AppRouteNames.tasks), MusicScene.calm);
    expect(musicSceneForRoute('/tasks/needs-01'), MusicScene.calm);
  });
}
