// Smoke test for FeatherRoadLink.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feather_road_link/main.dart';
import 'package:feather_road_link/screens/loader_screen.dart';

void main() {
  testWidgets('App boots into the branded loader', (WidgetTester tester) async {
    await tester.pumpWidget(const FeatherRoadLinkApp());
    await tester.pump();

    expect(find.byType(LoaderScreen), findsOneWidget);
    expect(find.text('LOADING…'), findsOneWidget);

    // Let the one-shot intro animations settle without entering the 8s wait.
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.byType(MaterialApp), findsOneWidget);

    // Tear the tree down so the loader's hand-off timers are cancelled.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
