import '../../data/models/expense_type_model.dart';
import '../repositories/expense_type_repository.dart';

class ExpenseTypeUsecase {
  final ExpenseTypeRepository repository;
  ExpenseTypeUsecase({required this.repository});
  Future<void> createType(ExpenseTypeModel type) async{
    return repository.createType(type);
  }

  Future<void> editType(ExpenseTypeModel type)async{
    return repository.editType(type);
  }

  Future<void> deleteType(int id)async{
    return repository.deleteType(id);
  }

  Future<List<ExpenseTypeModel>> getAllType()async{
    return repository.getAllType();
  }

  Future<ExpenseTypeModel?> getTypebyId(int typeId) async{
    return repository.getTypebyId(typeId);
  }
}