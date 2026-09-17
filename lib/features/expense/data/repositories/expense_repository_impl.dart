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
  Future<void> addExpense(ExpenseModel expense) async{
    try {
      await localDatasource.addExpense(expense);
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<void> editExpense(ExpenseModel expense) async {
    try {
      await localDatasource.editExpense(expense);
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    try {
      await localDatasource.deleteExpense(expenseId);
    } catch (e) {
      throw Exception("$e");
    }
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

  @override
  Future<List<ExpenseModel>> getExpenseList() async{
    try {
      List<ExpenseModel> expenseList = [];
      expenseList = await localDatasource.getExpenseList();
      return expenseList;
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<double> getTotalExpense() async{
    try {
      double total = await localDatasource.getTotalExpense();
      return total;
    } catch (e) {
      throw Exception("$e");
    }
  }

}
