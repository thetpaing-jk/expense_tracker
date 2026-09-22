import 'package:expense_tracker/features/budget/data/models/budget_model.dart';
import 'package:expense_tracker/features/budget/data/providers/budget_data_provider.dart';
import 'package:expense_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budget/screens/providers/budget_provider.dart';
import 'package:expense_tracker/features/budget/screens/providers/budget_provider_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBudgetRepository implements BudgetRepository {
  double total = 0;
  final List<BudgetModel> budgets = [];

  @override
  Future<void> addBudget(BudgetModel budget) async {
    budgets.insert(
      0,
      BudgetModel(
        id: budgets.length + 1,
        name: budget.name,
        amount: budget.amount,
      ),
    );
    total += budget.amount;
  }

  @override
  Future<List<BudgetModel>> getBudgetList() async => budgets;

  @override
  Future<double> getCurrentBudget() async => total;
}

void main() {
  test('saving budgets increases the current budget', () async {
    final repository = _FakeBudgetRepository();
    final container = ProviderContainer(
      overrides: [budgetRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container
        .read(budgetProvider.notifier)
        .addBudget(const BudgetModel(name: 'Salary', amount: 500));
    await container
        .read(budgetProvider.notifier)
        .addBudget(const BudgetModel(name: 'Bonus', amount: 250));

    final state = container.read(budgetProvider);
    expect(state, isA<BudgetSuccessState>());
    expect((state as BudgetSuccessState).currentBudget, 750);
    final budgets = await container.read(budgetListProvider.future);
    expect(budgets.map((budget) => budget.name), ['Bonus', 'Salary']);
  });
}
