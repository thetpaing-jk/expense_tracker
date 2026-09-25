import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../expense/data/models/expense_model.dart';
import '../../domain/models/expense_calculator_models.dart';
import '../../domain/usecases/expense_calculator.dart';

enum ExpenseCalculatorStatus { editing, calculating, result }

class ExpenseCalculatorState {
  final String incomeText;
  final List<CalculatorExpenseEntry> entries;
  final ExpenseCalculatorStatus status;
  final ExpenseCalculatorResult? result;
  final String? errorMessage;

  const ExpenseCalculatorState({
    this.incomeText = '',
    required this.entries,
    this.status = ExpenseCalculatorStatus.editing,
    this.result,
    this.errorMessage,
  });

  ExpenseCalculatorState copyWith({
    String? incomeText,
    List<CalculatorExpenseEntry>? entries,
    ExpenseCalculatorStatus? status,
    ExpenseCalculatorResult? result,
    bool clearResult = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExpenseCalculatorState(
      incomeText: incomeText ?? this.incomeText,
      entries: entries ?? this.entries,
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final expenseCalculatorProvider =
    NotifierProvider<ExpenseCalculatorNotifier, ExpenseCalculatorState>(
      ExpenseCalculatorNotifier.new,
    );

class ExpenseCalculatorNotifier extends Notifier<ExpenseCalculatorState> {
  int _nextId = 1;

  @override
  ExpenseCalculatorState build() {
    return ExpenseCalculatorState(entries: [_newEntry()]);
  }

  CalculatorExpenseEntry _newEntry({
    String title = '',
    String amountText = '',
    int? sourceExpenseId,
  }) {
    return CalculatorExpenseEntry(
      id: _nextId++,
      title: title,
      amountText: amountText,
      sourceExpenseId: sourceExpenseId,
    );
  }

  void updateIncome(String value) {
    state = state.copyWith(incomeText: value, clearError: true);
  }

  void addExpense() {
    state = state.copyWith(
      entries: [...state.entries, _newEntry()],
      clearError: true,
    );
  }

  void updateExpense(int id, {String? title, String? amountText}) {
    state = state.copyWith(
      entries: state.entries
          .map(
            (entry) => entry.id == id
                ? entry.copyWith(title: title, amountText: amountText)
                : entry,
          )
          .toList(growable: false),
      clearError: true,
    );
  }

  void removeExpense(int id) {
    final remaining = state.entries.where((entry) => entry.id != id).toList();
    state = state.copyWith(
      entries: remaining.isEmpty ? [_newEntry()] : remaining,
      clearError: true,
    );
  }

  int importExpenses(List<ExpenseModel> expenses) {
    final existingIds = state.entries
        .map((entry) => entry.sourceExpenseId)
        .whereType<int>()
        .toSet();
    final imported = expenses
        .where((expense) {
          return expense.id != null && !existingIds.contains(expense.id);
        })
        .map(
          (expense) => _newEntry(
            title: expense.title,
            amountText: expense.amount.toStringAsFixed(2),
            sourceExpenseId: expense.id,
          ),
        );
    final importedList = imported.toList(growable: false);
    final hasOnlyBlankRow =
        state.entries.length == 1 &&
        state.entries.first.title.trim().isEmpty &&
        state.entries.first.amountText.trim().isEmpty;
    state = state.copyWith(
      entries: [
        if (!hasOnlyBlankRow) ...state.entries,
        ...importedList,
        if (importedList.isEmpty && hasOnlyBlankRow) ...state.entries,
      ],
      clearError: true,
    );
    return importedList.length;
  }

  Future<void> calculate(List<ExpenseModel> expenseHistory) async {
    final incomeText = state.incomeText.trim();
    final income = incomeText.isEmpty ? null : double.tryParse(incomeText);
    if (incomeText.isNotEmpty && (income == null || income <= 0)) {
      state = state.copyWith(
        errorMessage: 'Enter a valid income amount or leave it blank.',
      );
      return;
    }
    final invalidEntry = state.entries.any(
      (entry) => entry.title.trim().isEmpty || (entry.amount ?? 0) <= 0,
    );
    if (invalidEntry) {
      state = state.copyWith(
        errorMessage: 'Every expense needs a title and an amount above zero.',
      );
      return;
    }

    state = state.copyWith(
      status: ExpenseCalculatorStatus.calculating,
      clearError: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 750));
    final result = ExpenseCalculator.calculate(
      entries: state.entries,
      expenseHistory: expenseHistory,
      income: income,
    );
    state = state.copyWith(
      status: ExpenseCalculatorStatus.result,
      result: result,
    );
  }

  void reset() {
    _nextId = 1;
    state = ExpenseCalculatorState(entries: [_newEntry()]);
  }
}
