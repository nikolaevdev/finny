import '../domain/shop_item.dart';

abstract final class ShopCatalog {
  static const items = <ShopItem>[
    ShopItem(
      id: 'food_set',
      title: 'Набор еды',
      price: 30,
      category: ShopCategory.need,
      effectLabel: 'Забота +10',
      careDelta: 10,
    ),
    ShopItem(
      id: 'fresh_water',
      title: 'Свежая вода',
      price: 15,
      category: ShopCategory.need,
      effectLabel: 'Забота +5',
      careDelta: 5,
    ),
    ShopItem(
      id: 'grooming',
      title: 'Уход за шерстью',
      price: 20,
      category: ShopCategory.need,
      effectLabel: 'Забота +8',
      careDelta: 8,
    ),
    ShopItem(
      id: 'sleep_place',
      title: 'Уютное место для сна',
      price: 25,
      category: ShopCategory.need,
      effectLabel: 'Забота +8',
      careDelta: 8,
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
      id: 'bandana',
      title: 'Бандана',
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
