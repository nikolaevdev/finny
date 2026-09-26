import 'game_state.dart';

abstract interface class GameStateRepository {
  GameState? load();

  Future<void> save(GameState state);

  Future<void> delete();
}
