import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/widgets/navigation_tile.dart';

void main() {
  testWidgets('NavigationTile renders correctly', (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NavigationTile(
            title: 'Go to Settings',
            description: 'Change app settings',
            icon: Icons.settings,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Go to Settings'), findsOneWidget);
    expect(find.text('Change app settings'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byType(NavigationTile));
    await tester.pump();
    expect(wasTapped, isTrue);
  });
}
