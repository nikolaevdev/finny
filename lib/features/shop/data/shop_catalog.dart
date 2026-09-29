import '../domain/shop_item.dart';

abstract final class ShopCatalog {
  static const items = <ShopItem>[
    ShopItem(
      id: 'food_set',
      title: 'Набор еды',
      price: 30,
      category: ShopCategory.need,
      effectLabel: 'Забота +10 · Настроение +2',
      careDelta: 10,
      moodDelta: 2,
    ),
    ShopItem(
      id: 'fresh_water',
      title: 'Свежая вода',
      price: 15,
      category: ShopCategory.need,
      effectLabel: 'Забота +5 · Настроение +1',
      careDelta: 5,
      moodDelta: 1,
    ),
    ShopItem(
      id: 'grooming',
      title: 'Уход за шерстью',
      price: 20,
      category: ShopCategory.need,
      effectLabel: 'Забота +8 · Настроение +2',
      careDelta: 8,
      moodDelta: 2,
    ),
    ShopItem(
      id: 'sleep_place',
      title: 'Уютное место для сна',
      price: 25,
      category: ShopCategory.need,
      effectLabel: 'Забота +8 · Настроение +3',
      careDelta: 8,
      moodDelta: 3,
      repeatable: false,
    ),
    ShopItem(
      id: 'ball',
      title: 'Мяч',
      price: 25,
      category: ShopCategory.want,
      effectLabel: 'Настроение +8',
      moodDelta: 8,
    ),
    ShopItem(
      id: 'explorer_journal',
      title: 'Дневник исследователя',
      price: 20,
      category: ShopCategory.want,
      effectLabel: 'Настроение +6',
      moodDelta: 6,
      repeatable: false,
    ),
    ShopItem(
      id: 'plant',
      title: 'Растение',
      price: 30,
      category: ShopCategory.want,
      effectLabel: 'Настроение +7',
      moodDelta: 7,
      repeatable: false,
    ),
    ShopItem(
      id: 'star_lamp',
      title: 'Звёздная лампа',
      price: 45,
      category: ShopCategory.want,
      effectLabel: 'Настроение +10',
      moodDelta: 10,
      repeatable: false,
    ),
  ];

  static ShopItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
