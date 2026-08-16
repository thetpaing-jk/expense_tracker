import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/utils/app_const.dart';
import '../../../expense_type/data/models/expense_type_model.dart';

abstract class ExpenseLocalDatasource {
  void addExpense();
  Future<List<ExpenseTypeModel>> getExpenseTypes();
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
  void addExpense() {
    // TODO: implement getExpenseTypes
  }

}