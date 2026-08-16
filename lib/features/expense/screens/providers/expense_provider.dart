import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'expense_provider_state.dart';

class ExpenseProvider extends Notifier<ExpenseProviderState>{
  @override
  build() {
    return ExpenseFormState();
  }
}