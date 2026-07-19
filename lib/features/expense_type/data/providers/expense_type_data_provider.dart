import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/expense_type_repository.dart';
import '../datasource/expense_type_local_datasource.dart';
import '../repositories/expense_type_repository_impl.dart';

final expenseLocalDatasourceProvider = Provider<ExpenseTypeLocalDatasource>((ref){
  return ExpenseTypeLocalDatasourceImpl();
});

final expenseRepositoryProvider = Provider<ExpenseTypeRepository>((ref){
  final datasource = ref.read(expenseLocalDatasourceProvider);
  return ExpenseTypeRepositoryImpl(
    localDatasource: datasource
  );
});