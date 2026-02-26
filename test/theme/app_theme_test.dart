import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/theme/app_theme.dart';
import 'package:wdict/theme/app_colors.dart';
import 'package:wdict/theme/app_decorations.dart';

void main() {
  group('AppTheme Tests', () {
    testWidgets('AppTheme configures colors, typography and borders', (
      WidgetTester tester,
    ) async {
      ThemeData? capturedTheme;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            capturedTheme = AppTheme.getTheme(context);
            return MaterialApp(
              theme: capturedTheme,
              home: const Scaffold(body: Text('Theme Test')),
            );
          },
        ),
      );

      final BuildContext context = tester.element(find.text('Theme Test'));
      final theme = Theme.of(context);

      // Verify basic paper white background
      expect(theme.scaffoldBackgroundColor, AppColors.paperWhite);

      // Verify charcoal text style
      expect(theme.textTheme.bodyLarge?.color, AppColors.charcoal);

      // Verify card theme uses SketchyBorder
      expect(theme.cardTheme.shape, isA<SketchyBorder>());
    });
  });
}
