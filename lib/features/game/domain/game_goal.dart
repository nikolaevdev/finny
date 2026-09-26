enum GameGoal {
  explorerCorner(
    id: 'explorer_corner',
    title: 'Уголок исследователя',
    cost: 180,
  ),
  treeHouse(
    id: 'tree_house',
    title: 'Домик Финни',
    cost: 260,
  ),
  festivalTrip(
    id: 'festival_trip',
    title: 'Поездка на фестиваль',
    cost: 320,
  );

  const GameGoal({
    required this.id,
    required this.title,
    required this.cost,
  });

  final String id;
  final String title;
  final int cost;

  static GameGoal fromId(Object? value) {
    for (final goal in GameGoal.values) {
      if (goal.id == value) return goal;
    }
    return GameGoal.explorerCorner;
  }
}
