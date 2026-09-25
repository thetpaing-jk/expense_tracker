import 'package:expense_tracker/features/budget/data/models/budget_model.dart';
import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/home/domain/usecases/home_summary_calculator.dart';
import 'package:expense_tracker/features/lucky_draw/data/models/lucky_draw_model.dart';
import 'package:flutter_test/flutter_test.dart';

ExpenseModel _expense(
  String date,
  double amount, {
  bool deductFromLuckyBudget = false,
}) {
  return ExpenseModel(
    title: 'Expense',
    amount: amount,
    type: 1,
    date: date,
    note: '',
    deductFromLuckyBudget: deductFromLuckyBudget,
  );
}

void main() {
  final expenses = [
    _expense('09-01-2026', 10),
    _expense('09-21-2026', 20),
    _expense('09-22-2026', 30),
    _expense('09-23-2026', 40),
    _expense('08-31-2026', 50),
  ];
  const budgets = [
    BudgetModel(name: 'Salary', amount: 3000),
    BudgetModel(name: 'Bonus', amount: 1000),
  ];

  test('today is fixed while period total follows the selected filter', () {
    final week = HomeSummaryCalculator.calculate(
      expenses: expenses,
      budgets: budgets,
      period: HomeExpensePeriod.thisWeek,
      now: DateTime(2026, 9, 23),
    );
    final month = HomeSummaryCalculator.calculate(
      expenses: expenses,
      budgets: budgets,
      period: HomeExpensePeriod.thisMonth,
      now: DateTime(2026, 9, 23),
    );

    expect(week.todayExpense, 40);
    expect(month.todayExpense, 40);
    expect(week.periodExpense, 90);
    expect(month.periodExpense, 100);
    expect(month.totalBudget, 4000);
  });

  test('lucky budget subtracts only checked expenses during draw period', () {
    final draw = LuckyDrawModel(
      id: 1,
      totalBudget: 400,
      period: 'custom',
      days: 3,
      minBudget: 10,
      maxBudget: 100,
      savedMoney: 0,
      tickets: const [],
      createdAt: DateTime(2026, 9, 21),
    );

    final summary = HomeSummaryCalculator.calculate(
      expenses: [
        _expense('09-21-2026', 20, deductFromLuckyBudget: true),
        _expense('09-22-2026', 30),
        _expense('09-23-2026', 40, deductFromLuckyBudget: true),
      ],
      budgets: budgets,
      period: HomeExpensePeriod.thisMonth,
      luckyDraw: draw,
      now: DateTime(2026, 9, 23),
    );

    expect(summary.luckyBudgetRemaining, 340);
  });

  test('lucky budget is absent when there is no lucky draw', () {
    final summary = HomeSummaryCalculator.calculate(
      expenses: expenses,
      budgets: budgets,
      period: HomeExpensePeriod.all,
      now: DateTime(2026, 9, 23),
    );

    expect(summary.periodExpense, 150);
    expect(summary.luckyBudgetRemaining, isNull);
  });

  test('category totals follow the selected period', () {
    final totals = HomeSummaryCalculator.categoryTotals(
      [
        ExpenseModel(
          id: 1,
          title: 'Lunch',
          amount: 20,
          type: 1,
          date: '09-22-2026',
          note: '',
        ),
        ExpenseModel(
          id: 2,
          title: 'Bus',
          amount: 30,
          type: 2,
          date: '09-23-2026',
          note: '',
        ),
        ExpenseModel(
          id: 3,
          title: 'Dinner',
          amount: 40,
          type: 1,
          date: '08-31-2026',
          note: '',
        ),
      ],
      period: HomeExpensePeriod.thisMonth,
      now: DateTime(2026, 9, 23),
    );

    expect(totals, {2: 30, 1: 20});
  });

  test('recent expenses are sorted newest first and limited', () {
    final recent = HomeSummaryCalculator.recentExpenses(expenses, limit: 3);

    expect(recent.map((expense) => expense.amount), [40, 30, 20]);
  });
}
