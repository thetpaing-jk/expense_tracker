import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_color.dart';
import '../../auth/screens/login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}
class _SplashScreenState extends ConsumerState<SplashScreen>{
  
  @override
  Widget build(BuildContext context) { 
    return Container();
  }
} 