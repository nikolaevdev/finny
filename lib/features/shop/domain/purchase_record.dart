import 'shop_item.dart';

class PurchaseRecord {
  const PurchaseRecord({
    required this.itemId,
    required this.title,
    required this.price,
    required this.category,
  });

  final String itemId;
  final String title;
  final int price;
  final ShopCategory category;

  Map<String, Object?> toJson() => {
        'itemId': itemId,
        'title': title,
        'price': price,
        'category': category.name,
      };

  factory PurchaseRecord.fromJson(Map<String, Object?> json) {
    final categoryName = json['category'];
    final category = ShopCategory.values.where(
      (value) => value.name == categoryName,
    );

    return PurchaseRecord(
      itemId: json['itemId'] is String ? json['itemId'] as String : '',
      title: json['title'] is String ? json['title'] as String : '',
      price: json['price'] is num ? (json['price'] as num).toInt() : 0,
      category: category.isEmpty ? ShopCategory.need : category.first,
    );
  }
}
