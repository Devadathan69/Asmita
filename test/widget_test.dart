import 'package:asmita/screens/entry/mode_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Asmita mode selection renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ModeSelectionScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Asmita'), findsWidgets);
    expect(find.text('Personal Tracking'), findsOneWidget);
  });
}
