import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouteHelper {
  // ============================================
  // Custom Transition Helper Functions
  // ============================================

  // Helper function: Slide from Right
  static CustomTransitionPage slideFromRight({required Widget child,required LocalKey key}) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Helper function: Slide from Bottom
  static CustomTransitionPage slideFromBottom({required Widget child,required LocalKey key}) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Helper function: Fade
  static CustomTransitionPage fadeTransition({required Widget child,required LocalKey key}) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: FadeTransition(
            opacity: ReverseAnimation(secondaryAnimation),
            child: child,
          ),
        );
      },
    );
  }

  // Helper function: Scale
  static CustomTransitionPage scaleTransition({required Widget child,required LocalKey key}) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }
}