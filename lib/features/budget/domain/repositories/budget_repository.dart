import '../../data/models/budget_model.dart';

abstract class BudgetRepository {
  Future<void> addBudget(BudgetModel budget);
  Future<List<BudgetModel>> getBudgetList();
  Future<double> getCurrentBudget();
}
