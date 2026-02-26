import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/widgets/custom_button.dart';
import 'package:wdict/theme/app_decorations.dart';

void main() {
  testWidgets('SketchyButton renders correctly and responds to tap', (
    WidgetTester tester,
  ) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SketchyButton(
            onPressed: () {
              wasTapped = true;
            },
            child: const Text('Tap Me'),
          ),
        ),
      ),
    );

    // Verify button text
    expect(find.text('Tap Me'), findsOneWidget);

    // Verify outer shape
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.style?.shape?.resolve({}) is SketchyBorder, isTrue);

    // Test tap
    await tester.tap(find.byType(SketchyButton));
    await tester.pump();
    expect(wasTapped, isTrue);
  });
}
