import 'package:expense_tracker/features/auth/screens/register_screen.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/root.dart';
import '../services/app_route_helper.dart';
import 'app_const.dart';

class AppRoutes {
  static final GoRouter  routes = GoRouter(
        navigatorKey: AppConst.navigatorKey,
        initialLocation: '/',
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
              ])
            ], builder: (context, state, navigationshellRoute){
              return RootWidget(navigationShell: navigationshellRoute);
            }
          ),
          // GoRoute(
          //   path: AppConst.splash,
          //   name: AppConst.splash,
          //   pageBuilder: (context, state) {
          //     return AppRouteHelper.fadeTransition(child: SplashScreen(), key: state.pageKey);
          //   },
          // ),
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