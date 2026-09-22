import '../../data/models/expense_model.dart';

sealed class ExpenseProviderState {}

class ExpenseLoadingState extends ExpenseProviderState {}

class ExpenseFormState extends ExpenseProviderState {}

class ExpenseSuccessState extends ExpenseProviderState {
  List<ExpenseModel> expenseList;
  String message;
  double total;
  ExpenseSuccessState({
    required this.expenseList,
    required this.total,
    this.message = "Success",
  });
}

class ExpenseErrorState extends ExpenseProviderState {
  String errorMessage;
  String systemErrorMessage;
  ExpenseErrorState({
    required this.errorMessage,
    required this.systemErrorMessage,
  });
}
