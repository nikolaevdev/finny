import 'package:flutter/foundation.dart';

@immutable
class GlossaryTerm {
  const GlossaryTerm({required this.title, required this.description});

  final String title;
  final String description;
}
