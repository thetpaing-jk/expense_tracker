import '../../../expense_type/data/models/expense_type_model.dart';
import '../../data/models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseUsecase {
  ExpenseRepository repository;
  ExpenseUsecase({
    required this.repository
  });
  Future<void> addExpense(ExpenseModel expense){
    return repository.addExpense(expense);
  }

  Future<void> editExpense(ExpenseModel expense){
    return repository.editExpense(expense);
  }

  Future<void> deleteExpense(int expenseId){
    return repository.deleteExpense(expenseId);
  }

  Future<List<ExpenseTypeModel>> getExpenseTypes(){
    return repository.getExpenseTypes();
  }

  Future<List<ExpenseModel>> getExpenseList() {
    return repository.getExpenseList();
  }
  Future<double> getTotalExpense() async{
    return repository.getTotalExpense();
  }
}
