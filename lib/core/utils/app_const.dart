import 'package:flutter/material.dart';

class AppConst {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String splash = '/splash';
  static const String home = '/dashboard';
  static const String login = '/';
  static const String register = '/register';
  static const String expense = '/expense';
  static const String expenseType = '/expenseType';
  static const String expenseTypeCreate = "/expenseTypeCreate";
  static const String settings = '/settings';
  static const String addExpenseScreen = '/addExpenseScreen';
  // static const String splash = '/';

  static const String userTable = 'userTable';
  static const String expenseTypeTable = 'expenseTypeTable';
  static const String expenseTable = 'expenseTable';

  static const String isLogined = "isLogined";

  static const String expneseTypeUrl = "assets/icon/types/";

  static const List<String> iconList = [
    "accommodation",
    "bus",
    "document",
    "expense",
    "food",
    "game",
    "medicine",
    "school",
    "shopping",
    "snack",
    "transportation",
  ];

  static const List<MaterialColor> colorList = [
    Colors.yellow,
    Colors.lightGreen,
    Colors.red,
    Colors.blue,
    Colors.grey,
    Colors.cyan,
    Colors.orange,
    Colors.amber,
    Colors.deepPurple,
    Colors.brown,
    Colors.indigo,
  ];
}
