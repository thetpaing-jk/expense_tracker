import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: ExpneseTracker()));
}

class ExpneseTracker extends StatefulWidget {
  const ExpneseTracker({super.key});

  @override
  State<ExpneseTracker> createState() => _ExpneseTrackerState();
}

class _ExpneseTrackerState extends State<ExpneseTracker> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: AppTheme.darkTheme,
      routerConfig: AppRoutes.router,
    );
  }
}
