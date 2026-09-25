import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/expense/data/providers/expense_data_provider.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/features/expense/screens/providers/expense_provider.dart';
import 'package:expense_tracker/features/expense/screens/providers/expense_provider_state.dart';
import 'package:expense_tracker/features/expense_type/data/models/expense_type_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseModel> expenses;

  _FakeExpenseRepository(this.expenses);

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    expenses.add(expense);
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    expenses.removeWhere((expense) => expense.id == expenseId);
  }

  @override
  Future<void> editExpense(ExpenseModel expense) async {
    final index = expenses.indexWhere((item) => item.id == expense.id);
    expenses[index] = expense;
  }

  @override
  Future<List<ExpenseModel>> getExpenseList() async =>
      List<ExpenseModel>.of(expenses);

  @override
  Future<List<ExpenseTypeModel>> getExpenseTypes() async => const [];

  @override
  Future<double> getTotalExpense() async =>
      expenses.fold<double>(0, (total, expense) => total + expense.amount);
}

void main() {
  test('editing an expense updates its Lucky budget choice', () async {
    final repository = _FakeExpenseRepository([
      ExpenseModel(
        id: 1,
        title: 'Lunch',
        amount: 100,
        type: 1,
        date: '09-24-2026',
        note: '',
        deductFromLuckyBudget: true,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [expenseRepository.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(expenseProvider.notifier)
        .editExpense(
          ExpenseModel(
            id: 1,
            title: 'Lunch',
            amount: 100,
            type: 1,
            date: '09-24-2026',
            note: '',
            deductFromLuckyBudget: false,
          ),
        );

    expect(container.read(expenseProvider), isA<ExpenseSuccessState>());
    final refreshedExpenses = await container.read(expenseListProvider.future);
    expect(refreshedExpenses.single.deductFromLuckyBudget, isFalse);
  });
}
