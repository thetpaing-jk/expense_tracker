import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/budget_model.dart';
import '../../domain/providers/budget_repository_provider.dart';
import '../../domain/usecases/budget_usecase.dart';
import 'budget_provider_state.dart';

final periodProvider = StateProvider<int>((ref) {
  return 0;
});

final budgetAmountSelectionProvider = StateProvider<int?>((ref) {
  return null;
});

final currentBudgetProvider = FutureProvider<double>((ref) {
  final usecase = ref.read(budgetUsecaseProvider);
  return usecase.getCurrentBudget();
});

final budgetProvider = BudgetNotifierProvider(() {
  return BudgetNotifier();
});

typedef BudgetNotifierProvider =
    NotifierProvider<BudgetNotifier, BudgetProviderState>;

class BudgetNotifier extends Notifier<BudgetProviderState> {
  BudgetUsecase get usecase => ref.read(budgetUsecaseProvider);

  @override
  BudgetProviderState build() {
    return BudgetFormState();
  }

  Future<void> addBudget(BudgetModel budget) async {
    try {
      state = BudgetLoadingState();
      await usecase.addBudget(budget);
      final currentBudget = await usecase.getCurrentBudget();
      ref.invalidate(currentBudgetProvider);
      state = BudgetSuccessState(currentBudget: currentBudget);
    } catch (error) {
      state = BudgetErrorState(
        errorMessage: 'Something went wrong while saving the budget',
        systemErrorMessage: error.toString(),
      );
    }
  }

  void resetForm() {
    state = BudgetFormState();
  }
}
