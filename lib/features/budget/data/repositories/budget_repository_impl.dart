import '../../domain/repositories/budget_repository.dart';
import '../datasource/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDatasource localDatasource;

  BudgetRepositoryImpl({required this.localDatasource});

  @override
  Future<void> addBudget(BudgetModel budget) {
    return localDatasource.addBudget(budget);
  }

  @override
  Future<double> getCurrentBudget() {
    return localDatasource.getCurrentBudget();
  }
}
