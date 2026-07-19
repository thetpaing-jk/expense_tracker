import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/expense_type_data_provider.dart';
import '../usecases/expense_type_usecase.dart';

final expenseTypeUsecaseProvider = Provider<ExpenseTypeUsecase>((ref){
  final repository = ref.read(expenseRepositoryProvider);
  return ExpenseTypeUsecase(repository: repository);
});