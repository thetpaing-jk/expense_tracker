import 'package:expense_tracker/features/expense/data/models/expense_model.dart';

import 'package:expense_tracker/features/expense_type/data/models/expense_type_model.dart';

import '../../domain/repositories/expense_repository.dart';
import '../datasource/expense_local_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository{
  ExpenseLocalDatasource localDatasource;
  ExpenseRepositoryImpl({
    required this.localDatasource
  });
  @override
  void addExpense(ExpenseModel expense) {

  }

  @override
  Future<List<ExpenseTypeModel>> getExpenseTypes() async{
    try {
      List<ExpenseTypeModel> expenseList = [];
      expenseList = await localDatasource.getExpenseTypes();
      return expenseList;
    } catch (e) {
      throw Exception("$e");
    }
  }

}