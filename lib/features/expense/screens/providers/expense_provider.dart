import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../../../budget/screens/providers/budget_provider.dart';
import '../../data/models/expense_model.dart';
import '../../domain/providers/expense_usecase_provider.dart';
import '../../domain/usecases/expense_usecase.dart';
import 'expense_provider_state.dart';

final expenseDateTime = StateProvider<String>(
  (ref) => DateFormat("MM-dd-yyyy").format(DateTime.now()),
);
final expenseProvider = ExpenseNotifierProvider(() => ExpenseProvider());
final expenseListProvider = FutureProvider<List<ExpenseModel>>((ref) {
  final usecase = ref.read(expenseUsecase);
  return usecase.getExpenseList();
});

typedef ExpenseNotifierProvider =
    NotifierProvider<ExpenseProvider, ExpenseProviderState>;

class ExpenseProvider extends Notifier<ExpenseProviderState> {
  ExpenseUsecase get usecase => ref.read(expenseUsecase);
  @override
  build() {
    return ExpenseFormState();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      state = ExpenseLoadingState();
      await usecase.addExpense(expense);
      ref.invalidate(expenseListProvider);
      ref.invalidate(currentBudgetProvider);
      List<ExpenseModel> expenseList = await usecase.getExpenseList();
      double totalExpense = await usecase.getTotalExpense();
      state = ExpenseSuccessState(
        expenseList: expenseList,
        total: totalExpense,
        message: "Successfully created",
      );
    } catch (e) {
      state = ExpenseErrorState(
        systemErrorMessage: "$e",
        errorMessage: "Something went Wrong",
      );
    }
  }

  Future<void> editExpense(ExpenseModel expense) async {
    try {
      state = ExpenseLoadingState();
      await usecase.editExpense(expense);
      ref.invalidate(expenseListProvider);
      ref.invalidate(currentBudgetProvider);
      List<ExpenseModel> expenseList = await usecase.getExpenseList();
      double totalExpense = await usecase.getTotalExpense();
      state = ExpenseSuccessState(
        expenseList: expenseList,
        total: totalExpense,
        message: "Successfully updated",
      );
    } catch (e) {
      state = ExpenseErrorState(
        systemErrorMessage: "$e",
        errorMessage: "Something went Wrong",
      );
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      await usecase.deleteExpense(expenseId);
      ref.invalidate(expenseListProvider);
      ref.invalidate(currentBudgetProvider);
      List<ExpenseModel> expenseList = await usecase.getExpenseList();
      double totalExpense = await usecase.getTotalExpense();
      state = ExpenseSuccessState(
        expenseList: expenseList,
        total: totalExpense,
        message: "Successfully deleted",
      );
    } catch (e) {
      state = ExpenseErrorState(
        systemErrorMessage: "$e",
        errorMessage: "Something went Wrong",
      );
    }
  }

  Future<void> getAllExpense() async {
    try {
      state = ExpenseLoadingState();
      List<ExpenseModel> expenseList = await usecase.getExpenseList();
      // double totalExpense = await usecase.getTotalExpense();
      double totalExpense = expenseList.fold(0.0, (sum, expense) {
        return sum + expense.amount;
      });
      state = ExpenseSuccessState(
        expenseList: expenseList,
        total: totalExpense,
      );
    } catch (e) {
      state = ExpenseErrorState(
        errorMessage: "Something went worng",
        systemErrorMessage: "$e",
      );
    }
  }
}
