import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/widgets/image_placeholder.dart';

void main() {
  testWidgets('SketchyImagePlaceholder renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SketchyImagePlaceholder(
            width: 100,
            height: 100,
            label: 'No Image',
          ),
        ),
      ),
    );

    expect(find.text('No Image'), findsOneWidget);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
}
