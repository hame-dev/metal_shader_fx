import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:metal_shader_fx/metal_shader_fx.dart';

void main() {
  testWidgets('MetalToggleCard applies size and toggles on interaction', (
    WidgetTester tester,
  ) async {
    bool toggledValue = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MetalToggleCard(
              value: false,
              accentColor: const Color(0xFFE3AA00),
              width: 760,
              height: 150,
              onChanged: (bool value) => toggledValue = value,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(MetalToggleCard)), const Size(760, 150));

    final Rect cardRect = tester.getRect(find.byType(MetalToggleCard));
    await tester.tapAt(Offset(cardRect.right - 40, cardRect.center.dy));
    await tester.pump();

    expect(toggledValue, isTrue);
  });

  testWidgets('MetallicBorderButton applies size and triggers onPressed', (
    WidgetTester tester,
  ) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetallicBorderButton(
            text: 'Continue',
            color: const Color(0xFF55267E),
            width: 280,
            height: 70,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(MetallicBorderButton)),
      const Size(280, 70),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('MetallicBorderTextField applies size and accepts text', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetallicBorderTextField(
            controller: controller,
            hintText: 'Enter your email',
            color: const Color(0xFFE3AA00),
            width: 320,
            height: 72,
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(MetallicBorderTextField)),
      const Size(320, 72),
    );

    await tester.enterText(find.byType(TextField), 'hello@example.com');
    await tester.pump();

    expect(controller.text, 'hello@example.com');
  });

  test('Exports include painter type', () {
    final painter = PhysicalMetalShinePainter(
      rotation: 0,
      energy: 1,
      tint: Colors.amber,
      borderRadius: 22,
      ringWidth: 3,
      isCircle: false,
    );

    expect(painter, isA<CustomPainter>());
  });
}
