import 'package:expense_tracker/features/budget/screens/budget_screen.dart';
import 'package:expense_tracker/features/budget/screens/budget_add_screen.dart';
import 'package:expense_tracker/features/expense/screens/expense_add.dart';
import 'package:expense_tracker/features/lucky_draw/screens/lucky_draw_create_screen.dart';
import 'package:expense_tracker/features/lucky_draw/screens/lucky_draw_history_screen.dart';
import 'package:expense_tracker/features/lucky_draw/screens/lucky_draw_screen.dart';
import 'package:expense_tracker/features/splash/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/expense/data/models/expense_model.dart';
import '../../features/expense/screens/expense.dart';
import '../../features/expense_calculator/screens/expense_calculator_screen.dart';
import '../../features/expense_type/data/models/expense_type_model.dart';
import '../../features/expense_type/screens/expense_type.dart';
import '../../features/expense_type/screens/expense_type_create.dart';
import '../../features/expense_type/screens/expense_type_expenses.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/lucky_draw/domain/usecases/lucky_draw_history_calculator.dart';
import '../../features/root.dart';
import '../../features/setting/screens/setting.dart';
import '../services/app_route_helper.dart';
import 'app_const.dart';

class AppRoutes {
  static final GoRouter routes = GoRouter(
    navigatorKey: AppConst.navigatorKey,
    // initialLocation: SharedPreferencesUtils.getBool(AppConst.isLogined) ? AppConst.home : AppConst.login ,
    initialLocation: AppConst.splash,
    // redirect: (context, state) {
    //   if(SharedPreferencesUtils.getBool(AppConst.isLogined)){
    //     return AppConst.home;
    //   }else{
    //     return AppConst.login;
    //   }
    // },
    routes: [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConst.home,
                name: AppConst.home,
                pageBuilder: (context, state) {
                  return AppRouteHelper.fadeTransition(
                    child: HomeScreen(),
                    key: state.pageKey,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConst.expense,
                name: AppConst.expense,
                pageBuilder: (context, state) {
                  return AppRouteHelper.fadeTransition(
                    child: ExpenseScreen(),
                    key: state.pageKey,
                  );
                },
                routes: [
                  GoRoute(
                    path: AppConst.addExpenseScreen,
                    name: AppConst.addExpenseScreen,
                    pageBuilder: (context, state) {
                      return AppRouteHelper.fadeTransition(
                        child: AddExpense(
                          expense: state.extra is ExpenseModel
                              ? state.extra as ExpenseModel
                              : null,
                        ),
                        key: state.pageKey,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConst.expenseType,
                name: AppConst.expenseType,
                pageBuilder: (context, state) {
                  return AppRouteHelper.fadeTransition(
                    child: ExpenseTypeScreen(),
                    key: state.pageKey,
                  );
                },
                routes: [
                  GoRoute(
                    path: AppConst.expenseTypeCreate,
                    name: AppConst.expenseTypeCreate,
                    pageBuilder: (context, state) {
                      ExpenseTypeModel? type;
                      if (state.extra != null) {
                        type = state.extra as ExpenseTypeModel;
                      }
                      return AppRouteHelper.fadeTransition(
                        child: ExpenseTypeCreateScreen(type: type),
                        key: state.pageKey,
                      );
                    },
                  ),
                  GoRoute(
                    path: AppConst.expenseTypeExpenses,
                    name: AppConst.expenseTypeExpenses,
                    pageBuilder: (context, state) {
                      return AppRouteHelper.slideFromRight(
                        child: ExpenseTypeExpensesScreen(
                          expenseType: state.extra as ExpenseTypeModel,
                        ),
                        key: state.pageKey,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConst.settings,
                name: AppConst.settings,
                pageBuilder: (context, state) {
                  return AppRouteHelper.fadeTransition(
                    child: SettingScreen(),
                    key: state.pageKey,
                  );
                },
              ),
            ],
          ),
        ],
        builder: (context, state, navigationshellRoute) {
          return RootWidget(navigationShell: navigationshellRoute);
        },
      ),
      GoRoute(
        path: AppConst.splash,
        name: AppConst.splash,
        pageBuilder: (context, state) {
          return AppRouteHelper.fadeTransition(
            child: SplashScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppConst.login,
        name: AppConst.login,
        pageBuilder: (context, state) {
          return AppRouteHelper.fadeTransition(
            child: LoginScreen(),
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 800),
          );
        },
      ),
      GoRoute(
        path: AppConst.register,
        name: AppConst.register,
        pageBuilder: (context, state) {
          return AppRouteHelper.fadeTransition(
            child: RegisterScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppConst.budget,
        name: AppConst.budget,
        pageBuilder: (context, state) {
          return AppRouteHelper.slideFromRight(
            child: BudgetScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppConst.budgetAdd,
        name: AppConst.budgetAdd,
        pageBuilder: (context, state) {
          return AppRouteHelper.slideFromRight(
            child: const BudgetAddScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppConst.expenseCalculator,
        name: AppConst.expenseCalculator,
        pageBuilder: (context, state) {
          return AppRouteHelper.slideFromRight(
            child: const ExpenseCalculatorScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/lucky-draw/create',
        name: 'lucky-draw-create',
        pageBuilder: (context, state) {
          return AppRouteHelper.slideFromRight(
            child: LuckyDrawCreateScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/lucky-draw',
        name: 'lucky-draw',
        pageBuilder: (context, state) {
          return AppRouteHelper.slideFromRight(
            child: LuckyDrawScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppConst.luckyDrawHistory,
        name: AppConst.luckyDrawHistory,
        pageBuilder: (context, state) {
          return AppRouteHelper.slideFromRight(
            child: const LuckyDrawHistoryScreen(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        path: AppConst.luckyDrawHistoryDetail,
        name: AppConst.luckyDrawHistoryDetail,
        pageBuilder: (context, state) {
          return AppRouteHelper.slideFromRight(
            child: LuckyDrawHistoryDetailScreen(
              entry: state.extra as LuckyDrawHistoryEntry,
            ),
            key: state.pageKey,
          );
        },
      ),
    ],
  );

  static GoRouter get router => routes;
}
