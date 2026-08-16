import 'package:expense_tracker/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/expense_repository.dart';
import '../datasource/expense_local_datasource.dart';

final expenseLocalDatasource = Provider<ExpenseLocalDatasource>((ref)=> ExpenseLocalDatasourceImpl());

final expenseRepository = Provider<ExpenseRepository>((ref){
  final localDatasource = ref.read(expenseLocalDatasource);
  return ExpenseRepositoryImpl(localDatasource: localDatasource);
});