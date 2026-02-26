import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/widgets/loading_indicator.dart';

void main() {
  testWidgets('SketchyLoadingIndicator renders correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SketchyLoadingIndicator(message: 'Please wait...', size: 50.0),
        ),
      ),
    );

    expect(find.text('Please wait...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
