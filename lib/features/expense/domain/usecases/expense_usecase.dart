import '../../../expense_type/data/models/expense_type_model.dart';
import '../../data/models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseUsecase {
  ExpenseRepository repository;
  ExpenseUsecase({
    required this.repository
  });
  void addExpense(ExpenseModel expense){
    return repository.addExpense(expense);
  }

  Future<List<ExpenseTypeModel>> getExpenseTypes(){
    return repository.getExpenseTypes();
  }
}