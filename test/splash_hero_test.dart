import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash logo flies to login in the navigator overlay', (tester) async {
    tester.view.physicalSize = const Size(480, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: ExpneseTracker()));
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);

    final flyingLogo = find.byWidgetPredicate((widget) => widget is Image).evaluate().where(
      (element) {
        var insideHero = false;
        element.visitAncestorElements((ancestor) {
          if (ancestor.widget is Hero) insideHero = true;
          return true;
        });
        return !insideHero;
      },
    ).toList();
    expect(flyingLogo, hasLength(1), reason: 'A flying logo should be in the overlay outside both Hero widgets.');
    final logoFinder = find.byWidget(flyingLogo.single.widget);
    final initialPosition = tester.getTopLeft(logoFinder);
    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(logoFinder).dy, lessThan(initialPosition.dy));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Welcome Back'), findsOneWidget);
    final destination = find.byWidgetPredicate((widget) => widget is Hero && widget.tag == 'icon');
    expect(destination, findsOneWidget);
    expect(find.descendant(of: destination, matching: find.byType(Image)), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
