import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_preference_helper.dart';
import '../../../core/utils/app_color.dart';
import '../../../core/utils/app_const.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final Animation<double> _progressBar;
  late final Animation<double> _opacityValue;
  late final Animation<Offset> _textSlideValue;
  late final Animation<double> _iconShadowColor;
  late final AnimationController _progressAnimationController;
  late final AnimationController _iconShadowAnimationController;
  late final AnimationController _opacityAnimationController;
  late final AnimationController _slideAnimationController;
  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _opacityAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _iconShadowAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _progressBar = Tween<double>(
      begin: 0.1,
      end: 1,
    ).animate(_progressAnimationController);
    _opacityValue = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(_opacityAnimationController);
    _textSlideValue = Tween<Offset>(begin: Offset(0, 2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.ease,
          ),
        );
    _iconShadowColor = Tween<double>(begin: 0, end: 0.26).animate(
      CurvedAnimation(
        parent: _iconShadowAnimationController,
        curve: Curves.ease,
      ),
    );
    _slideAnimationController.forward();
    _opacityAnimationController.forward();
    _progressAnimationController.forward();
    _iconShadowAnimationController.repeat(reverse: true);
    redirect();
  }

  void redirect() async {
    await Future.delayed(Duration(milliseconds: 3500));
    if (mounted) {
      if (SharedPreferencesUtils.getBool(AppConst.isLogined)) {
        context.pushNamed(AppConst.home);
      } else {
        context.pushNamed(AppConst.login);
      }
    }
  }

  @override
  void dispose() {
    _opacityAnimationController.dispose();
    _slideAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: Hero(
              tag: "icon",
              child: AnimatedBuilder(
                animation: _iconShadowColor,
                builder: (context, child) {
                  return Container(
                    height: 120,
                    width: 120,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColor.cardBackgroundColor,
                      border: Border.all(width: 2, color: AppColor.borderColor),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        // Close glow, followed by two softer outer aura layers.
                        BoxShadow(
                          color: AppColor.buttonColor.withValues(
                            alpha: _iconShadowColor.value,
                          ),
                          blurRadius: 72,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                    child: Image.asset('assets/icon/purse.png'),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text("Spendr", style: TextTheme.of(context).headlineLarge),
          const SizedBox(height: 8),
          SlideTransition(
            position: _textSlideValue,
            child: FadeTransition(
              opacity: _opacityValue,
              child: Text(
                "EXPENSE TRACKER",
                style: TextTheme.of(context).bodySmall!.copyWith(
                  color: AppColor.buttonColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * .4,
            child: AnimatedBuilder(
              animation: _progressBar,
              builder: (context, child) {
                return LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(90),
                  value: _progressBar.value,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "v1.0.0",
            style: TextTheme.of(context).labelMedium!.copyWith(
              color: AppColor.secondaryTextColor.withValues(alpha: .5),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
