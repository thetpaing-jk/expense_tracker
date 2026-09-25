import 'package:intl/intl.dart';

import '../../data/models/expense_model.dart';

enum ExpenseDateFilter { thisWeek, thisMonth, custom }

class ExpenseDateFilterService {
  ExpenseDateFilterService._();

  static List<ExpenseModel> filterAndSort(
    List<ExpenseModel> expenses, {
    required ExpenseDateFilter filter,
    DateTime? customStart,
    DateTime? customEnd,
    DateTime? now,
  }) {
    final today = dateOnly(now ?? DateTime.now());
    late final DateTime start;
    late final DateTime end;

    switch (filter) {
      case ExpenseDateFilter.thisWeek:
        start = today.subtract(Duration(days: today.weekday - DateTime.monday));
        end = start.add(const Duration(days: 6));
      case ExpenseDateFilter.thisMonth:
        start = DateTime(today.year, today.month);
        end = DateTime(today.year, today.month + 1, 0);
      case ExpenseDateFilter.custom:
        start = dateOnly(customStart ?? today);
        end = dateOnly(customEnd ?? customStart ?? today);
    }

    final normalizedStart = start.isAfter(end) ? end : start;
    final normalizedEnd = end.isBefore(start) ? start : end;
    final filtered = expenses.where((expense) {
      final date = parseExpenseDate(expense.date);
      if (date == null) return false;
      return !date.isBefore(normalizedStart) && !date.isAfter(normalizedEnd);
    }).toList();

    filtered.sort((first, second) {
      final firstDate = parseExpenseDate(first.date)!;
      final secondDate = parseExpenseDate(second.date)!;
      final dateComparison = secondDate.compareTo(firstDate);
      if (dateComparison != 0) return dateComparison;
      return (second.id ?? 0).compareTo(first.id ?? 0);
    });
    return filtered;
  }

  static Map<DateTime, List<ExpenseModel>> groupByDay(
    List<ExpenseModel> sortedExpenses,
  ) {
    final grouped = <DateTime, List<ExpenseModel>>{};
    for (final expense in sortedExpenses) {
      final date = parseExpenseDate(expense.date);
      if (date == null) continue;
      grouped.putIfAbsent(date, () => []).add(expense);
    }
    return grouped;
  }

  static double luckyBudgetTotalForDate(
    Iterable<ExpenseModel> expenses,
    DateTime date,
  ) {
    final targetDate = dateOnly(date);
    return expenses.fold<double>(0, (total, expense) {
      if (!expense.deductFromLuckyBudget) return total;
      final expenseDate = parseExpenseDate(expense.date);
      if (expenseDate == null || expenseDate != targetDate) return total;
      return total + expense.amount;
    });
  }

  static List<ExpenseModel> expensesForType(
    Iterable<ExpenseModel> expenses,
    int typeId,
  ) {
    final filtered = expenses
        .where((expense) => expense.type == typeId)
        .toList();
    filtered.sort((first, second) {
      final firstDate = parseExpenseDate(first.date);
      final secondDate = parseExpenseDate(second.date);
      final dateComparison = switch ((firstDate, secondDate)) {
        (final DateTime first, final DateTime second) => second.compareTo(
          first,
        ),
        (null, final DateTime _) => 1,
        (final DateTime _, null) => -1,
        (null, null) => 0,
      };
      if (dateComparison != 0) return dateComparison;
      return (second.id ?? 0).compareTo(first.id ?? 0);
    });
    return filtered;
  }

  static DateTime? parseExpenseDate(String value) {
    try {
      return dateOnly(DateFormat('MM-dd-yyyy').parseStrict(value));
    } on FormatException {
      final parsed = DateTime.tryParse(value);
      return parsed == null ? null : dateOnly(parsed);
    }
  }

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
