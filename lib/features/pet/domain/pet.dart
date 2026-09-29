import 'package:flutter/foundation.dart';

import 'pet_appearance.dart';

@immutable
class Pet {
  const Pet({
    required this.name,
    required this.appearance,
  });

  final String name;
  final PetAppearance appearance;

  Map<String, Object?> toJson() => {
        'name': name,
        'appearance': appearance.toJson(),
      };

  factory Pet.fromJson(Map<String, Object?> json) {
    final rawName = json['name'];
    final name = rawName is String ? rawName.trim() : '';
    if (name.isEmpty) {
      throw const FormatException('Pet name is missing');
    }

    final rawAppearance = json['appearance'];
    if (rawAppearance is! Map) {
      throw const FormatException('Pet appearance is missing');
    }

    return Pet(
      name: name,
      appearance: PetAppearance.fromJson(
        Map<String, Object?>.from(rawAppearance),
      ),
    );
  }
}
