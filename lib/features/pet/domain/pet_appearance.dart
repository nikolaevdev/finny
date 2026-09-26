import 'package:flutter/foundation.dart';

@immutable
class PetAppearance {
  const PetAppearance({
    required this.colorIndex,
    required this.earsIndex,
    required this.patternIndex,
  });

  final int colorIndex;
  final int earsIndex;
  final int patternIndex;

  Map<String, Object?> toJson() => {
        'colorIndex': colorIndex,
        'earsIndex': earsIndex,
        'patternIndex': patternIndex,
      };

  factory PetAppearance.fromJson(Map<String, Object?> json) {
    return PetAppearance(
      colorIndex: _safeVariantIndex(json['colorIndex']),
      earsIndex: _safeVariantIndex(json['earsIndex']),
      patternIndex: _safeVariantIndex(json['patternIndex']),
    );
  }

  static int _safeVariantIndex(Object? value) {
    final index = value is num ? value.toInt() : 0;
    return index >= 0 && index <= 2 ? index : 0;
  }
}
