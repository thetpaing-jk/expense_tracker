import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/expense/domain/usecases/expense_date_filter.dart';
import 'package:flutter_test/flutter_test.dart';

ExpenseModel _expense(int id, String date, double amount) {
  return ExpenseModel(
    id: id,
    title: 'Expense $id',
    amount: amount,
    type: 1,
    date: date,
    note: '',
  );
}

void main() {
  final expenses = [
    _expense(1, '09-01-2026', 10),
    _expense(2, '09-14-2026', 20),
    _expense(3, '09-15-2026', 30),
    _expense(4, '09-20-2026', 40),
    _expense(5, '08-31-2026', 50),
  ];

  test('this month is inclusive and sorted newest first', () {
    final result = ExpenseDateFilterService.filterAndSort(
      expenses,
      filter: ExpenseDateFilter.thisMonth,
      now: DateTime(2026, 9, 20),
    );

    expect(result.map((expense) => expense.id), [4, 3, 2, 1]);
  });

  test('this week starts on Monday and ends on Sunday', () {
    final result = ExpenseDateFilterService.filterAndSort(
      expenses,
      filter: ExpenseDateFilter.thisWeek,
      now: DateTime(2026, 9, 16),
    );

    expect(result.map((expense) => expense.id), [4, 3, 2]);
  });

  test('custom filter supports a single day and date range', () {
    final oneDay = ExpenseDateFilterService.filterAndSort(
      expenses,
      filter: ExpenseDateFilter.custom,
      customStart: DateTime(2026, 9, 15),
      customEnd: DateTime(2026, 9, 15),
    );
    final range = ExpenseDateFilterService.filterAndSort(
      expenses,
      filter: ExpenseDateFilter.custom,
      customStart: DateTime(2026, 9, 14),
      customEnd: DateTime(2026, 9, 15),
    );

    expect(oneDay.map((expense) => expense.id), [3]);
    expect(range.map((expense) => expense.id), [3, 2]);
  });

  test('groupByDay creates one group per date', () {
    final duplicatedDay = [...expenses, _expense(6, '09-15-2026', 5)];
    final sorted = ExpenseDateFilterService.filterAndSort(
      duplicatedDay,
      filter: ExpenseDateFilter.thisMonth,
      now: DateTime(2026, 9, 20),
    );
    final grouped = ExpenseDateFilterService.groupByDay(sorted);

    expect(grouped.length, 4);
    expect(grouped[DateTime(2026, 9, 15)]?.length, 2);
  });
}
