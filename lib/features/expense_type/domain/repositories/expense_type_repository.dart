import '../../data/models/expense_type_model.dart';

abstract class ExpenseTypeRepository {
  Future<void> createType(ExpenseTypeModel type);
  Future<void> editType(ExpenseTypeModel type);
  Future<void> deleteType(int id);
  Future<List<ExpenseTypeModel>> getAllType();
  Future<ExpenseTypeModel?> getTypebyId(int typeId);
}