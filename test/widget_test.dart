import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:organizador/main.dart';

void main() {
  testWidgets('File Organizer smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(FileOrganizerApp());

    // Verify that our file organizer starts with the correct title.
    expect(find.text('Organizador de Archivos'), findsOneWidget);
    expect(find.text('Mis Archivos'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));

    // Verify that our file organizer starts with the correct title.
    expect(find.text('Organizador de Archivos'), findsOneWidget);
    expect(find.text('Mis Archivos'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
