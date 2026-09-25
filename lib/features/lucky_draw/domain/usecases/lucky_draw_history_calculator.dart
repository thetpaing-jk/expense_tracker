import '../../../expense/data/models/expense_model.dart';
import '../../../expense/domain/usecases/expense_date_filter.dart';
import '../../data/models/lucky_draw_model.dart';

class LuckyDrawHistoryEntry {
  final LuckyDrawModel draw;
  final LuckyDrawTicket ticket;
  final DateTime date;
  final List<ExpenseModel> expenses;
  final double spentAmount;

  const LuckyDrawHistoryEntry({
    required this.draw,
    required this.ticket,
    required this.date,
    required this.expenses,
    required this.spentAmount,
  });

  double get difference => ticket.amount - spentAmount;
  bool get isOverBudget => difference < 0;
  double get remainingAmount => difference > 0 ? difference : 0;
  double get overBudgetAmount => difference < 0 ? -difference : 0;
  double get progress => ticket.amount <= 0
      ? 0
      : (spentAmount / ticket.amount).clamp(0.0, 1.0).toDouble();
}

class LuckyDrawHistoryCalculator {
  LuckyDrawHistoryCalculator._();

  static List<LuckyDrawHistoryEntry> build({
    required Iterable<LuckyDrawModel> draws,
    required Iterable<ExpenseModel> expenses,
  }) {
    final luckyExpensesByDate = <DateTime, List<ExpenseModel>>{};
    for (final expense in expenses) {
      if (!expense.deductFromLuckyBudget) continue;
      final date = ExpenseDateFilterService.parseExpenseDate(expense.date);
      if (date == null) continue;
      luckyExpensesByDate.putIfAbsent(date, () => []).add(expense);
    }

    final entries = <LuckyDrawHistoryEntry>[];
    for (final draw in draws) {
      for (final ticket in draw.tickets) {
        final drawnAt = ticket.drawnAt?.toLocal();
        if (!ticket.drawn || drawnAt == null) continue;
        final date = ExpenseDateFilterService.dateOnly(drawnAt);
        final matchedExpenses = List<ExpenseModel>.of(
          luckyExpensesByDate[date] ?? const <ExpenseModel>[],
        )..sort((first, second) => (second.id ?? 0).compareTo(first.id ?? 0));
        final spentAmount = matchedExpenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );
        entries.add(
          LuckyDrawHistoryEntry(
            draw: draw,
            ticket: ticket,
            date: date,
            expenses: matchedExpenses,
            spentAmount: spentAmount,
          ),
        );
      }
    }
    entries.sort((first, second) => second.date.compareTo(first.date));
    return entries;
  }
}
