import '../../data/models/budget_model.dart';
import '../repositories/budget_repository.dart';

class BudgetUsecase {
  final BudgetRepository repository;

  BudgetUsecase({required this.repository});

  Future<void> addBudget(BudgetModel budget) {
    return repository.addBudget(budget);
  }

  Future<double> getCurrentBudget() {
    return repository.getCurrentBudget();
  }
}
