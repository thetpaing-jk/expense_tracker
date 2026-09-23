import '../../../expense/data/models/expense_model.dart';
import '../../../expense/domain/usecases/expense_date_filter.dart';
import '../models/expense_calculator_models.dart';

class ExpenseCalculator {
  ExpenseCalculator._();

  static ExpenseCalculatorResult calculate({
    required List<CalculatorExpenseEntry> entries,
    required List<ExpenseModel> expenseHistory,
    double? income,
    DateTime? now,
  }) {
    final validEntries = entries
        .where(
          (entry) => entry.title.trim().isNotEmpty && (entry.amount ?? 0) > 0,
        )
        .toList(growable: false);
    final totalExpenses = validEntries.fold<double>(
      0,
      (sum, entry) => sum + entry.amount!,
    );
    final safeIncome = income != null && income > 0 ? income : null;
    final balance = (safeIncome ?? 0) - totalExpenses;
    final recommendedIncome = totalExpenses / .8;
    final additionalIncomeNeeded = safeIncome == null
        ? totalExpenses
        : balance < 0
        ? -balance
        : 0.0;
    final breakdown = validEntries.map((entry) {
      final amount = entry.amount!;
      return CalculatorBreakdownItem(
        title: entry.title.trim(),
        amount: amount,
        percentage: totalExpenses == 0 ? 0 : amount / totalExpenses * 100,
      );
    }).toList()..sort((first, second) => second.amount.compareTo(first.amount));

    return ExpenseCalculatorResult(
      income: safeIncome,
      totalExpenses: totalExpenses,
      balance: balance,
      minimumIncome: totalExpenses,
      recommendedIncome: recommendedIncome,
      additionalIncomeNeeded: additionalIncomeNeeded,
      breakdown: breakdown,
      suggestions: _buildSuggestions(
        totalExpenses: totalExpenses,
        income: safeIncome,
        recommendedIncome: recommendedIncome,
        breakdown: breakdown,
        expenseHistory: expenseHistory,
        now: now ?? DateTime.now(),
      ),
    );
  }

  static List<String> _buildSuggestions({
    required double totalExpenses,
    required double? income,
    required double recommendedIncome,
    required List<CalculatorBreakdownItem> breakdown,
    required List<ExpenseModel> expenseHistory,
    required DateTime now,
  }) {
    final suggestions = <String>[];
    final largest = breakdown.isEmpty ? null : breakdown.first;

    if (income == null) {
      suggestions.add(
        'Set your monthly income target above the minimum cover amount. '
        'The recommended target also keeps a 20% savings buffer.',
      );
    } else if (income < totalExpenses) {
      suggestions.add(
        'Your expenses are above your income. Close the shortfall first, '
        'then work toward the recommended income target.',
      );
    } else if (income < recommendedIncome) {
      suggestions.add(
        'You can cover these expenses, but less than 20% remains. '
        'Aim to keep at least one fifth of income for savings or emergencies.',
      );
    } else {
      suggestions.add(
        'This plan is balanced and leaves at least 20% of income available. '
        'Move that surplus to savings before adding new spending.',
      );
    }

    if (largest != null && largest.percentage >= 30) {
      suggestions.add(
        '“${largest.title}” is the largest item at '
        '${largest.percentage.toStringAsFixed(0)}% of this plan. Review it first '
        'if you need to reduce spending.',
      );
    }

    final monthlyTotals = <String, double>{};
    final historicalTitleTotals = <String, double>{};
    final historicalTitleLabels = <String, String>{};
    var historicalTotal = 0.0;
    for (final expense in expenseHistory) {
      final date = ExpenseDateFilterService.parseExpenseDate(expense.date);
      if (date == null || date.isAfter(now)) continue;
      final key = '${date.year}-${date.month}';
      monthlyTotals.update(
        key,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
      final titleKey = expense.title.trim().toLowerCase();
      if (titleKey.isNotEmpty) {
        historicalTitleLabels.putIfAbsent(titleKey, () => expense.title.trim());
        historicalTitleTotals.update(
          titleKey,
          (total) => total + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
      historicalTotal += expense.amount;
    }
    if (monthlyTotals.isNotEmpty) {
      final monthlyAverage =
          monthlyTotals.values.fold<double>(0, (sum, amount) => sum + amount) /
          monthlyTotals.length;
      if (totalExpenses > monthlyAverage * 1.15) {
        suggestions.add(
          'This plan is noticeably higher than your recorded monthly average. '
          'Check whether any item is a one-time expense.',
        );
      } else if (totalExpenses < monthlyAverage * .85) {
        suggestions.add(
          'This plan is below your recorded monthly average. Keep the difference '
          'as savings instead of treating it as extra spending money.',
        );
      }
    }

    if (historicalTitleTotals.isNotEmpty && historicalTotal > 0) {
      final topEntry = historicalTitleTotals.entries.reduce(
        (first, second) => first.value >= second.value ? first : second,
      );
      final share = topEntry.value / historicalTotal * 100;
      if (share >= 25) {
        suggestions.add(
          'Across all recorded expenses, “${historicalTitleLabels[topEntry.key]}” '
          'takes the largest share at ${share.toStringAsFixed(0)}%. Consider '
          'setting a limit for this expense.',
        );
      }
    }

    return suggestions;
  }
}
