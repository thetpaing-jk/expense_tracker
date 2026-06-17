import 'dart:ui';

import 'package:expense_tracker/core/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/navigation_provider.dart';

class RootWidget extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const RootWidget({super.key, required this.navigationShell});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends ConsumerState<RootWidget> {
  late List navigationList = [];
  @override
  void initState() {
    super.initState();
    navigationList = [
      NavigationItem(icon: Icons.home, index: 0),
      NavigationItem(icon: Icons.wallet, index: 1),
      NavigationItem(icon: Icons.type_specimen, index: 2),
      NavigationItem(icon: Icons.settings, index: 3),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColor.cardBackgroundColor.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [...navigationList],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem extends ConsumerStatefulWidget {
  final IconData icon;
  final int index;
  const NavigationItem({super.key, required this.icon, required this.index});

  @override
  ConsumerState<NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends ConsumerState<NavigationItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController iconAnimationController;
  late final Animation<double> iconAnimation;

  @override
  void initState() {
    super.initState();
    iconAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    iconAnimation = Tween<double>(begin: 25, end: 40).animate(
      CurvedAnimation(
        parent: iconAnimationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = ref.watch(navigationProvider);
    return GestureDetector(
      onTap: () {
        ref.read(navigationProvider.notifier).state = widget.index;
        iconAnimationController.forward();
        Future.delayed(Duration(milliseconds: 200)).then((_) {
          iconAnimationController.reverse();
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 100),
            width: widget.index == navProvider ? 25 : 0,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.buttonColor,
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          SizedBox(height :widget.index == navProvider ? 4 : 0),
          AnimatedBuilder(
            animation: iconAnimation,
            builder: (context, _) {
              return Icon(widget.icon, size: iconAnimation.value);
            },
          ),
        ],
      ),
    );
  }
}
