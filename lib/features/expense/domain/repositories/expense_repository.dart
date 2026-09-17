import '../../../expense_type/data/models/expense_type_model.dart';
import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseTypeModel>> getExpenseTypes();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> editExpense(ExpenseModel expense);
  Future<void> deleteExpense(int expenseId);
  Future<List<ExpenseModel>> getExpenseList();
  Future<double> getTotalExpense();
}
