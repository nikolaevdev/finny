enum ShopCategory { need, want }

class ShopItem {
  const ShopItem({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.effectLabel,
    this.careDelta = 0,
    this.moodDelta = 0,
    this.repeatable = true,
  });

  final String id;
  final String title;
  final int price;
  final ShopCategory category;
  final String effectLabel;
  final int careDelta;
  final int moodDelta;
  final bool repeatable;
}
