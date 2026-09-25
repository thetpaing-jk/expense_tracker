import 'package:expense_tracker/core/services/app_number_formatter.dart';
import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/expense/screens/providers/expense_provider.dart';
import 'package:expense_tracker/features/lucky_draw/data/models/lucky_draw_model.dart';
import 'package:expense_tracker/features/lucky_draw/screens/lucky_draw_history_screen.dart';
import 'package:expense_tracker/features/lucky_draw/screens/providers/lucky_draw_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('history screen shows matched spending and over-budget status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final draw = LuckyDrawModel(
      id: 1,
      totalBudget: 100,
      period: 'custom',
      days: 1,
      maxBudget: 50,
      savedMoney: 50,
      tickets: [
        LuckyDrawTicket(
          id: 1,
          drawId: 1,
          ticketNo: 1,
          amount: 50,
          drawn: true,
          drawnAt: DateTime(2026, 9, 24, 10),
        ),
      ],
      createdAt: DateTime(2026, 9, 24),
    );
    final expenses = [
      ExpenseModel(
        id: 1,
        title: 'Lunch',
        amount: 60,
        type: 1,
        date: '09-24-2026',
        note: '',
        deductFromLuckyBudget: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          luckyDrawHistoryProvider.overrideWith((ref) async => [draw]),
          expenseListProvider.overrideWith((ref) async => expenses),
        ],
        child: const AppCurrencyScope(
          currency: AppCurrency.baht,
          child: MaterialApp(home: LuckyDrawHistoryScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lucky Draw History'), findsOneWidget);
    expect(find.text('Ticket #1'), findsOneWidget);
    expect(find.textContaining('Over'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
