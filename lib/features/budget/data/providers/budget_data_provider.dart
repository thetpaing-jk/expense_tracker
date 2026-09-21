import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/budget_repository.dart';
import '../datasource/budget_local_datasource.dart';
import '../repositories/budget_repository_impl.dart';

final budgetLocalDatasourceProvider = Provider<BudgetLocalDatasource>((ref) {
  return BudgetLocalDatasourceImpl();
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final datasource = ref.read(budgetLocalDatasourceProvider);
  return BudgetRepositoryImpl(localDatasource: datasource);
});
