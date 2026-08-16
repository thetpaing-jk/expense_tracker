import '../../data/models/expense_model.dart';

sealed class ExpenseProviderState {}

class ExpenseLoadingState extends ExpenseProviderState{}

class ExpenseFormState extends ExpenseProviderState{}

class ExpenseSuccessState extends ExpenseProviderState{
  List<ExpenseModel> expenseList;
  String message;
  ExpenseSuccessState({
    required this.expenseList,
    this.message = "Success"
  });
}

class ExpenseErrorState extends ExpenseProviderState{
  String errorMessage;
  ExpenseErrorState(
    {
      required this.errorMessage
    }
  );
}