import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wdict/widgets/custom_list_tile.dart';

void main() {
  testWidgets('SketchyListTile renders correctly', (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SketchyListTile(
            title: const Text('Main Title'),
            subtitle: const Text('Subtitle info'),
            leading: const Icon(Icons.star),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Main Title'), findsOneWidget);
    expect(find.text('Subtitle info'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

    await tester.tap(find.byType(SketchyListTile));
    await tester.pump();
    expect(wasTapped, isTrue);
  });
}
