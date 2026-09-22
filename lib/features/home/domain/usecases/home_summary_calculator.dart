import '../../../budget/data/models/budget_model.dart';
import '../../../expense/data/models/expense_model.dart';
import '../../../expense/domain/usecases/expense_date_filter.dart';
import '../../../lucky_draw/data/models/lucky_draw_model.dart';

enum HomeExpensePeriod {
  thisWeek('This Week'),
  thisMonth('This Month'),
  all('All');

  final String label;
  const HomeExpensePeriod(this.label);
}

class HomeSummaryData {
  final double todayExpense;
  final double periodExpense;
  final double totalBudget;
  final double? luckyBudgetRemaining;

  const HomeSummaryData({
    required this.todayExpense,
    required this.periodExpense,
    required this.totalBudget,
    required this.luckyBudgetRemaining,
  });
}

class HomeSummaryCalculator {
  HomeSummaryCalculator._();

  static HomeSummaryData calculate({
    required List<ExpenseModel> expenses,
    required List<BudgetModel> budgets,
    required HomeExpensePeriod period,
    LuckyDrawModel? luckyDraw,
    DateTime? now,
  }) {
    final today = ExpenseDateFilterService.dateOnly(now ?? DateTime.now());
    final todayExpense = _totalBetween(expenses, today, today);
    final periodExpense = expensesForPeriod(
      expenses,
      period: period,
      now: today,
    ).fold<double>(0, (sum, expense) => sum + expense.amount);
    final totalBudget = budgets.fold<double>(
      0,
      (sum, budget) => sum + budget.amount,
    );

    double? luckyBudgetRemaining;
    if (luckyDraw != null) {
      final start = ExpenseDateFilterService.dateOnly(
        luckyDraw.createdAt.toLocal(),
      );
      final programEnd = start.add(Duration(days: luckyDraw.days - 1));
      final effectiveEnd = programEnd.isBefore(today) ? programEnd : today;
      final spentDuringProgram = effectiveEnd.isBefore(start)
          ? 0.0
          : _totalBetween(expenses, start, effectiveEnd);
      luckyBudgetRemaining = luckyDraw.totalBudget - spentDuringProgram;
    }

    return HomeSummaryData(
      todayExpense: todayExpense,
      periodExpense: periodExpense,
      totalBudget: totalBudget,
      luckyBudgetRemaining: luckyBudgetRemaining,
    );
  }

  static List<ExpenseModel> expensesForPeriod(
    List<ExpenseModel> expenses, {
    required HomeExpensePeriod period,
    DateTime? now,
  }) {
    final today = ExpenseDateFilterService.dateOnly(now ?? DateTime.now());
    late final DateTime start;
    switch (period) {
      case HomeExpensePeriod.thisWeek:
        start = today.subtract(Duration(days: today.weekday - DateTime.monday));
      case HomeExpensePeriod.thisMonth:
        start = DateTime(today.year, today.month);
      case HomeExpensePeriod.all:
        return List<ExpenseModel>.of(expenses);
    }
    return expenses
        .where((expense) {
          final date = ExpenseDateFilterService.parseExpenseDate(expense.date);
          return date != null && !date.isBefore(start) && !date.isAfter(today);
        })
        .toList(growable: false);
  }

  static Map<int, double> categoryTotals(
    List<ExpenseModel> expenses, {
    required HomeExpensePeriod period,
    DateTime? now,
  }) {
    final totals = <int, double>{};
    for (final expense in expensesForPeriod(
      expenses,
      period: period,
      now: now,
    )) {
      totals.update(
        expense.type,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final entries = totals.entries.toList()
      ..sort((first, second) => second.value.compareTo(first.value));
    return Map<int, double>.fromEntries(entries);
  }

  static List<ExpenseModel> recentExpenses(
    List<ExpenseModel> expenses, {
    int limit = 3,
  }) {
    final sorted = List<ExpenseModel>.of(expenses)
      ..sort((first, second) {
        final firstDate = ExpenseDateFilterService.parseExpenseDate(first.date);
        final secondDate = ExpenseDateFilterService.parseExpenseDate(
          second.date,
        );
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
    return sorted.take(limit).toList(growable: false);
  }

  static double _totalBetween(
    List<ExpenseModel> expenses,
    DateTime start,
    DateTime end,
  ) {
    return expenses.fold<double>(0, (sum, expense) {
      final date = ExpenseDateFilterService.parseExpenseDate(expense.date);
      if (date == null || date.isBefore(start) || date.isAfter(end)) return sum;
      return sum + expense.amount;
    });
  }
}
