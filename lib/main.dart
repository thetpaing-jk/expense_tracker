import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/app_preference_helper.dart';
import 'core/services/app_number_formatter.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';
import 'features/setting/screens/providers/setting_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesUtils.intiSharePreference();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: ExpneseTracker()));
}

class ExpneseTracker extends ConsumerWidget {
  const ExpneseTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRoutes.router,
      builder: (context, child) {
        return AppCurrencyScope(
          currency: currency,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
