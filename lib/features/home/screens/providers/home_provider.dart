import 'package:flutter_riverpod/legacy.dart';

import '../../domain/usecases/home_summary_calculator.dart';

final dropdownProvider = StateProvider<HomeExpensePeriod>((ref) {
  return HomeExpensePeriod.thisMonth;
});

final draggableProvider = StateProvider<bool>((ref) {
  return false;
});
