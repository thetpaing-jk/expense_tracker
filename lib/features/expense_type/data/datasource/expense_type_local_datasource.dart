

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/utils/app_const.dart';
import '../models/expense_type_model.dart';

abstract class ExpenseTypeLocalDatasource{
  Future<void> createType(ExpenseTypeModel type);
  Future<void> deleteType(int typeId);
  Future<void> editType(ExpenseTypeModel type);
  Future<List<ExpenseTypeModel>> getAllType();
}

class ExpenseTypeLocalDatasourceImpl implements ExpenseTypeLocalDatasource {
  final DatabaseService _database;
  ExpenseTypeLocalDatasourceImpl({DatabaseService? databaseService})
  : _database = databaseService ?? DatabaseService.instance;
  @override
  Future<void> createType(ExpenseTypeModel type) async{
    try {
      Database db = await _database.database;
      await db.insert(AppConst.expenseTypeTable, type.toJson());
    } catch (e) {
      debugPrint("ExpenseTypeLocalDatasource insert type error : $e");
      throw Exception("$e");
    }
  }

  @override
  Future<void> deleteType(int typeId) async{
    try {
      Database db = await _database.database;
      await db.delete(
        AppConst.expenseTypeTable,
        where: "id = ?",
        whereArgs: [typeId],
      );
    } catch (e) {
      debugPrint("ExpenseTypeLocalDatasource delete type error : $e");
      throw Exception("$e");
    }
  }

  @override
  Future<void> editType(ExpenseTypeModel type) async {
    try {
      Database db = await _database.database;
      await db.update(AppConst.expenseTypeTable, type.toJson(), where: "id = ?", whereArgs: [type.id]);
    } catch (e) {
      debugPrint("ExpenseTypeLocalDatasource update type error : $e");
      throw Exception("$e");
    }
  }
  
  @override
  Future<List<ExpenseTypeModel>> getAllType() async{
    try {
      Database db = await _database.database;
      List<ExpenseTypeModel> typeList = [];
      List<Map<String,dynamic>> data = await db.query(AppConst.expenseTypeTable);
      if(data.isNotEmpty){
        typeList = data.map((e)=>ExpenseTypeModel.fromJson(e)).toList();
      }
      return typeList;
    } catch (e) {
      debugPrint("ExpenseTypeLocalDatasource get All type error : $e");
      throw Exception("$e");
    }
  }
}
