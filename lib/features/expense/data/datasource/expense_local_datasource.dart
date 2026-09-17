import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/utils/app_const.dart';
import '../../../expense_type/data/models/expense_type_model.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDatasource {
  Future<void> addExpense(ExpenseModel expense);
  Future<void> editExpense(ExpenseModel expense);
  Future<void> deleteExpense(int expenseId);
  Future<List<ExpenseTypeModel>> getExpenseTypes();
  Future<List<ExpenseModel>> getExpenseList();
  Future<double> getTotalExpense();
}

class ExpenseLocalDatasourceImpl implements ExpenseLocalDatasource{
  final DatabaseService? _databaseService;
  ExpenseLocalDatasourceImpl({
    DatabaseService? databaseService
  }):_databaseService = DatabaseService.instance;
  @override
  Future<List<ExpenseTypeModel>> getExpenseTypes() async{
    try {
      Database db = await _databaseService!.database;
      List<ExpenseTypeModel> expenseTypeList = [];
      List<Map<String,dynamic>> data = await db.query(AppConst.expenseTypeTable);
      expenseTypeList = data.map((element)=> ExpenseTypeModel.fromJson(element)).toList();
      return expenseTypeList;
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async{
    try {
      Database db = await _databaseService!.database;
      Map<String,dynamic> expenseData = expense.toJson();
      await db.insert(AppConst.expenseTable, expenseData);
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<void> editExpense(ExpenseModel expense) async {
    try {
      Database db = await _databaseService!.database;
      await db.update(
        AppConst.expenseTable,
        expense.toJson(),
        where: "id = ?",
        whereArgs: [expense.id],
      );
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<void> deleteExpense(int expenseId) async {
    try {
      Database db = await _databaseService!.database;
      await db.delete(
        AppConst.expenseTable,
        where: "id = ?",
        whereArgs: [expenseId],
      );
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenseList() async{
    try {
      Database db = await _databaseService!.database;
      List<Map<String,dynamic>> data = await db.query(AppConst.expenseTable);
      List<ExpenseModel> expenseList = data.map((element)=> ExpenseModel.fromJson(element)).toList();
      return expenseList;
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<double> getTotalExpense() async{
    try {
      Database db = await _databaseService!.database;
      List<Map<String,dynamic>> data = await db.rawQuery("Select SUM(amount) as total from ${AppConst.expenseTable}");
      double totalAmount = data.first['total'] ?? 0.0;
      return totalAmount;
    } catch (e) {
      throw Exception("$e");
    }
  }
}
