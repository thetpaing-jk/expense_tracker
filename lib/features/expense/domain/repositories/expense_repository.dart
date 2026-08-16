import '../../../expense_type/data/models/expense_type_model.dart';
import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseTypeModel>> getExpenseTypes();
  void addExpense(ExpenseModel expense);
}