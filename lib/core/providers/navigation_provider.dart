import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

final navigationProvider = StateProvider<int>((ref){
  return 0;
});

final navShellProvider = StateProvider<StatefulNavigationShell?>((ref){
  return null;
});