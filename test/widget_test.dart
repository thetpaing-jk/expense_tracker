import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts inside its provider scope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ExpneseTracker()),
    );
    await tester.pump();

    expect(find.text('Spendr'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 3500));
  });
}
