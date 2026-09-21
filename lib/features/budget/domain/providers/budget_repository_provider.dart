import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/budget_data_provider.dart';
import '../usecases/budget_usecase.dart';

final budgetUsecaseProvider = Provider<BudgetUsecase>((ref) {
  final repository = ref.read(budgetRepositoryProvider);
  return BudgetUsecase(repository: repository);
});
