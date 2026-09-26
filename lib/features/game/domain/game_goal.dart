enum GameGoal {
  explorerCorner(
    id: 'explorer_corner',
    title: 'Уголок исследователя',
    cost: 180,
    resultText: 'У Финни появился свой уголок для идей, книг и маленьких открытий.',
  ),
  treeHouse(
    id: 'tree_house',
    title: 'Домик Финни',
    cost: 260,
    resultText: 'Финни получил уютный домик – большая цель стала настоящим результатом.',
  ),
  festivalTrip(
    id: 'festival_trip',
    title: 'Поездка на фестиваль',
    cost: 320,
    resultText: 'Финни накопил на поездку и теперь может отправиться на фестиваль.',
  );

  const GameGoal({
    required this.id,
    required this.title,
    required this.cost,
    required this.resultText,
  });

  final String id;
  final String title;
  final int cost;
  final String resultText;

  String get lesson =>
      'Вывод: если регулярно откладывать часть монет и не тратить накопления раньше времени, большая цель становится достижимой.';

  static GameGoal fromId(Object? value) {
    for (final goal in GameGoal.values) {
      if (goal.id == value) return goal;
    }
    return GameGoal.explorerCorner;
  }
}
