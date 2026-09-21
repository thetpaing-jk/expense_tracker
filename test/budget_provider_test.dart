import 'package:expense_tracker/features/budget/data/models/budget_model.dart';
import 'package:expense_tracker/features/budget/data/providers/budget_data_provider.dart';
import 'package:expense_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budget/screens/providers/budget_provider.dart';
import 'package:expense_tracker/features/budget/screens/providers/budget_provider_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBudgetRepository implements BudgetRepository {
  double total = 0;

  @override
  Future<void> addBudget(BudgetModel budget) async {
    total += budget.amount;
  }

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
        .addBudget(const BudgetModel(amount: 500));
    await container
        .read(budgetProvider.notifier)
        .addBudget(const BudgetModel(amount: 250));

    final state = container.read(budgetProvider);
    expect(state, isA<BudgetSuccessState>());
    expect((state as BudgetSuccessState).currentBudget, 750);
    expect(await container.read(currentBudgetProvider.future), 750);
  });
}
