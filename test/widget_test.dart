import 'package:asmita/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Asmita opens to mode selection', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AsmitaApp()));
    await tester.pump();
    expect(find.text('Asmita'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Personal Tracking'), findsOneWidget);
  });
}
