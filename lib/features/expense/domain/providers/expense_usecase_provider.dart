import 'package:expense_tracker/features/expense/data/providers/expense_data_provider.dart';
import 'package:expense_tracker/features/expense/domain/usecases/expense_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseUsecase = Provider((ref){
  final repository = ref.read(expenseRepository);
  ExpenseUsecase(repository: repository);
});