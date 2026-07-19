import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/expense/screens/expense.dart';
import '../../features/expense_type/data/models/expense_type_model.dart';
import '../../features/expense_type/screens/expense_type.dart';
import '../../features/expense_type/screens/expense_type_create.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/root.dart';
import '../../features/setting/screens/setting.dart';
import '../services/app_preference_helper.dart';
import '../services/app_route_helper.dart';
import 'app_const.dart';

class AppRoutes {
  static final GoRouter  routes = GoRouter(
        navigatorKey: AppConst.navigatorKey,
        initialLocation: SharedPreferencesUtils.getBool(AppConst.isLogined) == true ? AppConst.home : '/',
        routes: [
          StatefulShellRoute.indexedStack(
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: AppConst.home,
                  name: AppConst.home,  
                  pageBuilder: (context, state){
                    return AppRouteHelper.fadeTransition(
                      child:  HomeScreen(),
                      key: state.pageKey);
                  }
                )
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: AppConst.expense,
                  name: AppConst.expense,
                  pageBuilder: (context, state) {
                    return AppRouteHelper.fadeTransition(child: ExpenseScreen(), key: state.pageKey);
                  },
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: AppConst.expenseType,
                  name: AppConst.expenseType,
                  pageBuilder: (context, state) {
                    return AppRouteHelper.fadeTransition(child: ExpenseTypeScreen(), key: state.pageKey);
                  },
                  routes: [
                    GoRoute(path: AppConst.expenseTypeCreate,
                      name: AppConst.expenseTypeCreate,
                      pageBuilder: (context, state){
                        ExpenseTypeModel? type = state.extra as ExpenseTypeModel;
                        return AppRouteHelper.slideFromRight(child: ExpenseTypeCreateScreen(
                          type: type,
                        ), key: state.pageKey);
                      }
                    )
                  ]
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(path: AppConst.settings,
                  name: AppConst.settings,
                  pageBuilder: (context, state) {
                    return AppRouteHelper.fadeTransition(child: SettingScreen(), key: state.pageKey);
                  },
                )
              ])
            ], builder: (context, state, navigationshellRoute){
              return RootWidget(navigationShell: navigationshellRoute);
            }
          ),
          GoRoute(
            path: AppConst.login,
            name: AppConst.login,
            pageBuilder: (context, state) {
              return AppRouteHelper.fadeTransition(child: LoginScreen(), key: state.pageKey);
            },
          ),
          GoRoute(path: AppConst.register,
            name: AppConst.register,
            pageBuilder: (context, state) {
              return AppRouteHelper.fadeTransition(child: RegisterScreen(), key: state.pageKey);
            },
          )
        ],
      );

      static GoRouter get router => routes;
}