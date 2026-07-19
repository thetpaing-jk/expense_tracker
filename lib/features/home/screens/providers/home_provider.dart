import 'package:flutter_riverpod/legacy.dart';

final dropdownProvider = StateProvider<String> ((ref){
  return "This Month";
});
