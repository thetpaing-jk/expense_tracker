import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_number_formatter.dart';
import '../../../core/utils/app_const.dart';
import '../data/models/lucky_draw_model.dart';
import 'providers/lucky_draw_provider.dart';
import 'providers/lucky_draw_provider_state.dart';
import 'widgets/congrats_overlay.dart';

class LuckyDrawScreen extends ConsumerStatefulWidget {
  const LuckyDrawScreen({super.key});

  @override
  ConsumerState<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends ConsumerState<LuckyDrawScreen>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _glowController;
  late final List<AnimationController> _flyControllers;
  late final Animation<double> _shakeRotation;
  late final Animation<double> _shakeScale;
  bool _isShaking = false;
  LuckyDrawModel? _lastDraw;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _flyControllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _shakeRotation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -0.14), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.14, end: 0.14), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.14, end: -0.10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.10, end: 0.10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.10, end: -0.07), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.07, end: 0.07), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.07, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
    _shakeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.08), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1), weight: 1),
    ]).animate(_shakeController);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraw());
  }

  Future<void> _loadDraw() async {
    await ref.read(luckyDrawProvider.notifier).getCurrentDraw();
    if (!mounted) return;
    if (ref.read(luckyDrawProvider) is LuckyDrawInitialState) {
      context.go('/lucky-draw/create');
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppConst.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(luckyDrawProvider);
    if (state is LuckyDrawReadyState) _lastDraw = state.draw;
    _listenForErrors();
    final draw = state is LuckyDrawReadyState ? state.draw : _lastDraw;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _handleBack),
        title: const Text('Lucky Draw 🎟️'),
        actions: [
          if (draw != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    '${draw.undrawnTickets.length} tickets',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          if (draw != null)
            PopupMenuButton<String>(
              tooltip: 'Lucky Draw menu',
              onSelected: (value) {
                if (value == 'delete') _confirmDelete(draw);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Lucky Draw'),
                ),
              ],
            ),
        ],
      ),
      body: draw == null
          ? state is LuckyDrawErrorState
                ? _ErrorBody(onRetry: _loadDraw)
                : const Center(child: CircularProgressIndicator.adaptive())
          : _buildDraw(context, draw, state is LuckyDrawLoadingState),
    );
  }

  Widget _buildDraw(BuildContext context, LuckyDrawModel draw, bool isLoading) {
    final colors = Theme.of(context).colorScheme;
    final progress = draw.tickets.isEmpty
        ? 0.0
        : draw.drawnCount / draw.tickets.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.secondary,
              border: Border.symmetric(
                horizontal: BorderSide(color: colors.outline),
              ),
            ),
            child: Row(
              children: [
                _StatItem(
                  label: 'Budget',
                  value: NumberFormatService.formatCurrency(
                    context,
                    draw.totalBudget,
                  ),
                ),
                _StatItem(
                  label: 'Drawn',
                  value: NumberFormatService.formatCurrency(
                    context,
                    draw.drawnAmount,
                  ),
                  valueColor: colors.tertiary,
                  showLeftBorder: true,
                ),
                _StatItem(
                  label: 'Saved',
                  value: NumberFormatService.formatCurrency(
                    context,
                    draw.savedMoney,
                  ),
                  valueColor: colors.primary,
                  showLeftBorder: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Center(child: _buildLotteryBox(draw, isLoading)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 98),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(4),
                  backgroundColor: colors.surfaceContainerHighest,
                ),
                const SizedBox(height: 6),
                Text(
                  '${draw.drawnCount} / ${draw.tickets.length} drawn',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              'Tickets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: draw.tickets.length,
            itemBuilder: (context, index) {
              final ticket = draw.tickets[index];
              return _TicketCard(ticket: ticket);
            },
          ),
          if (draw.savedMoney > 0) ...[
            const SizedBox(height: 18),
            _SavedMoneyCard(draw: draw),
          ],
          if (draw.undrawnTickets.isEmpty) ...[
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      'All tickets have been drawn!',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => _deleteAndCreate(draw.id),
                      child: const Text('Start a New Lucky Draw'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLotteryBox(LuckyDrawModel draw, bool isLoading) {
    final colors = Theme.of(context).colorScheme;
    final disabled = isLoading || _isShaking || draw.undrawnTickets.isEmpty;
    final label = draw.undrawnTickets.isEmpty
        ? 'DRAW COMPLETE'
        : draw.hasDrawnToday
        ? 'COME BACK TOMORROW'
        : 'TAP TO DRAW';

    return SizedBox(
      width: 220,
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (_isShaking)
            for (var index = 0; index < 3; index++)
              Positioned(
                top: 18,
                left: 88 + (index - 1) * 28,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset.zero,
                    end: Offset((index - 1) * 0.3, -1.2),
                  ).animate(_flyControllers[index]),
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 1,
                      end: 0.3,
                    ).animate(_flyControllers[index]),
                    child: const Text('🎟', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
          AnimatedBuilder(
            animation: Listenable.merge([_shakeController, _glowController]),
            builder: (context, child) {
              final glow = 20 + _glowController.value * 30;
              return Transform.rotate(
                angle: _shakeRotation.value,
                child: Transform.scale(
                  scale: _shakeScale.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _isShaking
                          ? [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.45),
                                blurRadius: glow,
                              ),
                            ]
                          : const [],
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: Material(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(26),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: disabled ? null : () => _drawTicket(draw),
                child: SizedBox(
                  width: 145,
                  height: 145,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎰', style: TextStyle(fontSize: 52)),
                      const SizedBox(height: 12),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: colors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _drawTicket(LuckyDrawModel draw) async {
    if (draw.hasDrawnToday) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Already drew today!')));
      return;
    }
    final available = draw.undrawnTickets;
    if (available.isEmpty) return;
    final selected = available[math.Random().nextInt(available.length)];

    setState(() => _isShaking = true);
    _glowController.repeat(reverse: true);
    for (var index = 0; index < _flyControllers.length; index++) {
      Future.delayed(Duration(milliseconds: index * 150), () {
        if (mounted && _isShaking) {
          _flyControllers[index].repeat(reverse: true);
        }
      });
    }
    await _shakeController.forward(from: 0);
    if (!mounted) return;
    _shakeController.reset();
    _glowController.stop();
    _glowController.reset();
    for (final controller in _flyControllers) {
      controller.stop();
      controller.reset();
    }
    setState(() => _isShaking = false);

    await ref.read(luckyDrawProvider.notifier).drawTicket(selected.id);
    if (!mounted) return;
    if (ref.read(luckyDrawProvider) is LuckyDrawReadyState) {
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return CongratsOverlay(
            amount: selected.amount,
            onClose: () => Navigator.of(dialogContext).pop(),
          );
        },
      );
    }
  }

  Future<void> _confirmDelete(LuckyDrawModel draw) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Lucky Draw?'),
        content: const Text('The draw and all of its tickets will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) await _deleteAndCreate(draw.id);
  }

  Future<void> _deleteAndCreate(int drawId) async {
    await ref.read(luckyDrawProvider.notifier).deleteDraw(drawId);
    if (mounted && ref.read(luckyDrawProvider) is LuckyDrawInitialState) {
      context.pushReplacement('/lucky-draw/create');
    }
  }

  void _listenForErrors() {
    ref.listen(luckyDrawProvider, (previous, next) {
      if (next is LuckyDrawErrorState) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage)));
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _glowController.dispose();
    for (final controller in _flyControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool showLeftBorder;

  const _StatItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.showLeftBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          border: showLeftBorder
              ? Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                )
              : null,
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final LuckyDrawTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: ticket.drawn
            ? colors.primary.withValues(alpha: 0.13)
            : colors.secondary,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: ticket.drawn
              ? colors.primary.withValues(alpha: 0.65)
              : colors.outline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '#${ticket.ticketNo}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Text(
            ticket.drawn ? ticket.amount.toStringAsFixed(2) : '?',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: ticket.drawn ? colors.primary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedMoneyCard extends StatelessWidget {
  final LuckyDrawModel draw;

  const _SavedMoneyCard({required this.draw});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🏦 Saved Money',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 7),
                Text(
                  NumberFormatService.formatCurrency(context, draw.savedMoney),
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Budget − ticket amounts = savings',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const Text('💚', style: TextStyle(fontSize: 34)),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBody({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load Lucky Draw.'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}
