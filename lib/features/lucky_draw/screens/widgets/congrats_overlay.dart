import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/services/app_number_formatter.dart';

class CongratsOverlay extends StatefulWidget {
  final double amount;
  final VoidCallback onClose;

  const CongratsOverlay({
    super.key,
    required this.amount,
    required this.onClose,
  });

  @override
  State<CongratsOverlay> createState() => _CongratsOverlayState();
}

class _CongratsOverlayState extends State<CongratsOverlay>
    with TickerProviderStateMixin {
  late final List<AnimationController> _starControllers;
  late final AnimationController _amountController;
  late final AnimationController _sweepController;
  late final List<AnimationController> _confettiControllers;
  late final AnimationController _closeController;
  late final List<double> _confettiX;
  late final List<double> _confettiDrift;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _starControllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _amountController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _confettiControllers = List.generate(
      6,
      (_) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1200 + random.nextInt(401)),
      ),
    );
    _confettiX = List.generate(6, (_) => 0.08 + random.nextDouble() * 0.84);
    _confettiDrift = List.generate(6, (_) => random.nextDouble() * 0.2 - 0.1);
    _closeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startSequence();
  }

  Future<void> _startSequence() async {
    for (var index = 0; index < _starControllers.length; index++) {
      Future.delayed(Duration(milliseconds: index * 150), () {
        if (mounted) _starControllers[index].forward();
      });
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _amountController.forward();
      _sweepController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      for (final controller in _confettiControllers) {
        controller.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _closeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final confettiColors = [
      colors.primary,
      colors.tertiary,
      Colors.blue,
      Colors.purple,
      colors.error,
      Colors.white,
    ];
    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                for (
                  var index = 0;
                  index < _confettiControllers.length;
                  index++
                )
                  AnimatedBuilder(
                    animation: _confettiControllers[index],
                    builder: (context, child) {
                      final value = _confettiControllers[index].value;
                      final opacity = value < 0.7 ? 1.0 : (1 - value) / 0.3;
                      return Positioned(
                        left:
                            (_confettiX[index] +
                                _confettiDrift[index] * value) *
                            constraints.maxWidth,
                        top: -20 + value * constraints.maxHeight * 1.1,
                        child: Opacity(
                          opacity: opacity.clamp(0, 1),
                          child: Transform.rotate(
                            angle: value * math.pi * 4,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: confettiColors[index],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var index = 0; index < 3; index++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ScaleTransition(
                              scale: CurvedAnimation(
                                parent: _starControllers[index],
                                curve: Curves.easeOutBack,
                              ),
                              child: RotationTransition(
                                turns: Tween<double>(
                                  begin: 0,
                                  end: 0.5,
                                ).animate(_starControllers[index]),
                                child: Text(
                                  index == 1 ? '🌟' : '⭐',
                                  style: const TextStyle(fontSize: 34),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.3, end: 1).animate(
                        CurvedAnimation(
                          parent: _amountController,
                          curve: const ElasticOutCurve(0.8),
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _sweepController,
                        builder: (context, child) {
                          return Container(
                            width: 210,
                            height: 210,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                transform: GradientRotation(
                                  _sweepController.value * math.pi * 2,
                                ),
                                colors: [
                                  colors.primary,
                                  colors.primary.withValues(alpha: 0.35),
                                  colors.secondary,
                                  colors.primary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.4),
                                  blurRadius: 36,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.secondary,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🎟️', style: TextStyle(fontSize: 34)),
                              const SizedBox(height: 8),
                              Text(
                                'Congratulations!',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                NumberFormatService.formatCurrency(
                                  context,
                                  widget.amount,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 38),
                    FadeTransition(
                      opacity: _closeController,
                      child: SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: widget.onClose,
                          child: const Text('Awesome!'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _starControllers) {
      controller.dispose();
    }
    _amountController.dispose();
    _sweepController.dispose();
    for (final controller in _confettiControllers) {
      controller.dispose();
    }
    _closeController.dispose();
    super.dispose();
  }
}
