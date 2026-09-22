import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/utils/app_const.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDatasource {
  Future<void> addBudget(BudgetModel budget);
  Future<List<BudgetModel>> getBudgetList();
  Future<double> getCurrentBudget();
}

class BudgetLocalDatasourceImpl implements BudgetLocalDatasource {
  final DatabaseService _databaseService;

  BudgetLocalDatasourceImpl({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  @override
  Future<void> addBudget(BudgetModel budget) async {
    try {
      final Database db = await _databaseService.database;
      await db.insert(AppConst.budgetTable, budget.toJson());
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<List<BudgetModel>> getBudgetList() async {
    try {
      final Database db = await _databaseService.database;
      final result = await db.query(AppConst.budgetTable, orderBy: 'id DESC');
      return result.map(BudgetModel.fromJson).toList(growable: false);
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<double> getCurrentBudget() async {
    try {
      final Database db = await _databaseService.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) AS total FROM ${AppConst.budgetTable}',
      );
      return (result.first['total'] as num?)?.toDouble() ?? 0;
    } catch (error) {
      throw Exception(error);
    }
  }
}
