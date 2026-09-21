sealed class BudgetProviderState {}

class BudgetFormState extends BudgetProviderState {}

class BudgetLoadingState extends BudgetProviderState {}

class BudgetSuccessState extends BudgetProviderState {
  final double currentBudget;
  final String message;

  BudgetSuccessState({
    required this.currentBudget,
    this.message = 'Budget saved successfully',
  });
}

class BudgetErrorState extends BudgetProviderState {
  final String errorMessage;
  final String systemErrorMessage;

  BudgetErrorState({
    required this.errorMessage,
    required this.systemErrorMessage,
  });
}
