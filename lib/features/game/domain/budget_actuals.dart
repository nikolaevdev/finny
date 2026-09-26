import '../../shop/domain/shop_item.dart';

class BudgetActuals {
  const BudgetActuals({
    this.needSpent = 0,
    this.wantSpent = 0,
    this.saved = 0,
  });

  final int needSpent;
  final int wantSpent;
  final int saved;

  int get totalSpent => needSpent + wantSpent;

  BudgetActuals addPurchase(ShopItem item) {
    return switch (item.category) {
      ShopCategory.need => BudgetActuals(
          needSpent: needSpent + item.price,
          wantSpent: wantSpent,
          saved: saved,
        ),
      ShopCategory.want => BudgetActuals(
          needSpent: needSpent,
          wantSpent: wantSpent + item.price,
          saved: saved,
        ),
    };
  }

  Map<String, Object?> toJson() => {
        'needSpent': needSpent,
        'wantSpent': wantSpent,
        'saved': saved,
      };

  factory BudgetActuals.fromJson(Map<String, Object?> json) {
    int safeAmount(Object? value) {
      final amount = value is num ? value.toInt() : 0;
      return amount < 0 ? 0 : amount;
    }

    return BudgetActuals(
      needSpent: safeAmount(json['needSpent']),
      wantSpent: safeAmount(json['wantSpent']),
      saved: safeAmount(json['saved']),
    );
  }
}
