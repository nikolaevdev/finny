import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const floating = <BoxShadow>[
    BoxShadow(
      color: Color(0x17000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
