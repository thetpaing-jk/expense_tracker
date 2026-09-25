import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/expense/screens/providers/expense_provider.dart';
import 'package:expense_tracker/features/expense_calculator/domain/models/expense_calculator_models.dart';
import 'package:expense_tracker/features/expense_calculator/domain/usecases/expense_calculator.dart';
import 'package:expense_tracker/features/expense_calculator/screens/expense_calculator_screen.dart';
import 'package:expense_tracker/features/expense_calculator/screens/providers/expense_calculator_provider.dart';
import 'package:expense_tracker/core/services/app_number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

CalculatorExpenseEntry _entry(int id, String title, String amount) {
  return CalculatorExpenseEntry(id: id, title: title, amountText: amount);
}

void main() {
  group('ExpenseCalculator', () {
    test('calculates a surplus and breakdown percentages', () {
      final result = ExpenseCalculator.calculate(
        entries: [_entry(1, 'Lunch', '12.5'), _entry(2, 'Taxi', '8')],
        expenseHistory: const [],
        income: 1000,
      );

      expect(result.totalExpenses, 20.5);
      expect(result.balance, 979.5);
      expect(result.isSurplus, isTrue);
      expect(result.additionalIncomeNeeded, 0);
      expect(result.breakdown.first.title, 'Lunch');
      expect(result.breakdown.first.percentage, closeTo(60.975, .001));
    });

    test('calculates deficit and extra income required', () {
      final result = ExpenseCalculator.calculate(
        entries: [_entry(1, 'Rent', '1200')],
        expenseHistory: const [],
        income: 1000,
      );

      expect(result.balance, -200);
      expect(result.additionalIncomeNeeded, 200);
      expect(result.isSurplus, isFalse);
    });

    test('suggests minimum and buffered income when income is omitted', () {
      final result = ExpenseCalculator.calculate(
        entries: [_entry(1, 'Rent', '800')],
        expenseHistory: const [],
      );

      expect(result.hasIncome, isFalse);
      expect(result.minimumIncome, 800);
      expect(result.recommendedIncome, 1000);
      expect(result.additionalIncomeNeeded, 800);
    });

    test('uses historical monthly data in advice', () {
      final result = ExpenseCalculator.calculate(
        entries: [_entry(1, 'Plan', '2000')],
        expenseHistory: [
          ExpenseModel(
            title: 'Food',
            amount: 500,
            type: 1,
            date: '09-01-2026',
            note: '',
          ),
          ExpenseModel(
            title: 'Travel',
            amount: 500,
            type: 2,
            date: '08-01-2026',
            note: '',
          ),
        ],
        now: DateTime(2026, 9, 23),
      );

      expect(
        result.suggestions.any((item) => item.contains('monthly average')),
        isTrue,
      );
    });
  });

  test('imports expenses from all dates without creating duplicates', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(expenseCalculatorProvider.notifier);
    final expenses = [
      ExpenseModel(
        id: 1,
        title: 'Older expense',
        amount: 25,
        type: 1,
        date: '08-01-2026',
        note: '',
      ),
      ExpenseModel(
        id: 2,
        title: 'Recent expense',
        amount: 30,
        type: 1,
        date: '09-23-2026',
        note: '',
      ),
    ];

    expect(notifier.importExpenses(expenses), 2);
    expect(
      container
          .read(expenseCalculatorProvider)
          .entries
          .map((entry) => entry.title),
      ['Older expense', 'Recent expense'],
    );
    expect(notifier.importExpenses(expenses), 0);
    expect(container.read(expenseCalculatorProvider).entries, hasLength(2));
  });

  testWidgets('calculator form displays an animated result', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseListProvider.overrideWith((ref) async => <ExpenseModel>[]),
        ],
        child: const AppCurrencyScope(
          currency: AppCurrency.baht,
          child: MaterialApp(home: ExpenseCalculatorScreen()),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('calculator-income')),
      '1000',
    );
    await tester.enterText(find.byKey(const ValueKey('title-1')), 'Food');
    await tester.enterText(find.byKey(const ValueKey('amount-1')), '250');
    final calculateButton = find.text('Calculate');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pump();

    expect(find.text('Evaluating your plan...'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Surplus'), findsOneWidget);
    expect(find.text('Smart Financial Advisor'), findsOneWidget);
    expect(find.textContaining('750.00'), findsOneWidget);
  });
}
