import 'dart:ui' show PointerDeviceKind;

import 'package:finny/core/widgets/finni_pressable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('glow can disappear without a negative shadow blur',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: FinniPressable(
              effect: FinniPressEffect.reward,
              child: SizedBox(width: 180, height: 72),
            ),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(FinniPressable)));
    await tester.pumpAndSettle();

    final glowing = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect((glowing.decoration! as BoxDecoration).boxShadow, isNotEmpty);

    await mouse.moveTo(Offset.zero);
    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 32));
      expect(tester.takeException(), isNull, reason: 'frame $i');
    }
    await mouse.removePointer();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
