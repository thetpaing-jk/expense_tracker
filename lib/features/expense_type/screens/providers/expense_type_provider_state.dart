import '../../data/models/expense_type_model.dart';

sealed class ExpenseTypeProviderState {}

class ExpenseTypeLoadingState extends ExpenseTypeProviderState{
  String type;
  ExpenseTypeLoadingState({
    required this.type
  });
}

class ExpenseTypeFormState extends ExpenseTypeProviderState{}

class ExpenseTypeSuccessState extends ExpenseTypeProviderState{
  String message;
  ExpenseTypeSuccessState({required this.message});
}

class ExpenseTypeErrorState extends ExpenseTypeProviderState{
  String errorMessage;
  ExpenseTypeErrorState({required this.errorMessage});
}

class ExpenseTypeReadyState extends ExpenseTypeProviderState{
  List<ExpenseTypeModel> expenseList;
  String message;
  ExpenseTypeReadyState({
    required this.expenseList,
    required this.message
  });
}