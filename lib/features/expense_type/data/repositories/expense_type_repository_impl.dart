

import 'package:flutter/widgets.dart';

import '../../domain/repositories/expense_type_repository.dart';
import '../datasource/expense_type_local_datasource.dart';
import '../models/expense_type_model.dart';

class ExpenseTypeRepositoryImpl implements ExpenseTypeRepository{
  final ExpenseTypeLocalDatasource localDatasource;
  ExpenseTypeRepositoryImpl({required this.localDatasource});
  @override
  Future<void> createType(ExpenseTypeModel type) async{
    try {
      await localDatasource.createType(type);
    } catch (e) {
      debugPrint("Expense Repository create type Error : $e");
      throw Exception("$e");
    }
  }

  @override
  Future<void> deleteType(int id) async{
    try {
      await localDatasource.deleteType(id);
    } catch (e) {
      debugPrint("Expense Repository delete type Error : $e");
      throw Exception("$e");
    }
  }

  @override
  Future<void> editType(ExpenseTypeModel type) async{
    try {
      await localDatasource.editType(type);
    } catch (e) {
      debugPrint("Expense Repository edit type Error : $e");
      throw Exception("$e");
    }
  }

  @override
  Future<List<ExpenseTypeModel>> getAllType() async{
    try {
      List<ExpenseTypeModel> data = await localDatasource.getAllType();
      return data;
    } catch (e) {
      debugPrint("Expense Repository get all type Error : $e");
      throw Exception("$e");
    }
  }
}
