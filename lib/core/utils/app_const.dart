import 'package:flutter/material.dart';

class AppConst {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String home = '/dashboard';
  static const String login = '/';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String settings = '/settings';
  // static const String splash = '/';

  static const String userTable = 'userTable';
  static const String expenseTypeTable = 'expenseTypeTable';
  static const String expenseTable = 'expenseTable';

  static const String isLogined = "isLogined";
}
