class CalculatorExpenseEntry {
  final int id;
  final String title;
  final String amountText;
  final int? sourceExpenseId;

  const CalculatorExpenseEntry({
    required this.id,
    this.title = '',
    this.amountText = '',
    this.sourceExpenseId,
  });

  double? get amount => double.tryParse(amountText.trim());

  CalculatorExpenseEntry copyWith({String? title, String? amountText}) {
    return CalculatorExpenseEntry(
      id: id,
      title: title ?? this.title,
      amountText: amountText ?? this.amountText,
      sourceExpenseId: sourceExpenseId,
    );
  }
}

class CalculatorBreakdownItem {
  final String title;
  final double amount;
  final double percentage;

  const CalculatorBreakdownItem({
    required this.title,
    required this.amount,
    required this.percentage,
  });
}

class ExpenseCalculatorResult {
  final double? income;
  final double totalExpenses;
  final double balance;
  final double minimumIncome;
  final double recommendedIncome;
  final double additionalIncomeNeeded;
  final List<CalculatorBreakdownItem> breakdown;
  final List<String> suggestions;

  const ExpenseCalculatorResult({
    required this.income,
    required this.totalExpenses,
    required this.balance,
    required this.minimumIncome,
    required this.recommendedIncome,
    required this.additionalIncomeNeeded,
    required this.breakdown,
    required this.suggestions,
  });

  bool get hasIncome => income != null;
  bool get isSurplus => hasIncome && balance >= 0;
}
